import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/wallet_history_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class UserService extends BaseFirestoreService {
  UserService({super.firestore});
  // User Profile
  Future<void> updateUserBankDetails(
    String userId,
    Map<String, dynamic> bankDetails,
  ) {
    return db.collection('users').doc(userId).update({
      'bank_details': bankDetails,
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return db.collection('users').doc(userId).update(data);
  }

  Stream<UserModel> getUserStream(String userId) {
    return db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      throw Exception('User not found');
    });
  }

  // Username Helpers
  Future<bool> checkUsernameExists(String username) async {
    final snapshot = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final snapshot = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  Future<UserModel?> resolveUser(String identifier) async {
    final userByUsername = await getUserByUsername(identifier);
    if (userByUsername != null) return userByUsername;

    final docSpan = await db.collection('users').doc(identifier).get();
    if (docSpan.exists) {
      return UserModel.fromMap(docSpan.data()!, docSpan.id);
    }
    return null;
  }

  // Admin User Management
  Stream<List<UserModel>> getAllMarketingUsers() {
    return db
        .collection('users')
        .where('role', isEqualTo: 'marketing')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteUser(String userId) {
    return db.collection('users').doc(userId).delete();
  }

  Future<void> updateAdminUser(String userId, Map<String, dynamic> data) {
    return db.collection('users').doc(userId).update(data);
  }

  Future<void> recalculateUserStats(String userId) async {
    final userRef = db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) return;

    final userData = userDoc.data();
    final String? marketingCategory = userData?['marketing_category'];

    final settingsDoc =
        await db.collection('global_settings').doc('config').get();
    final settings = settingsDoc.exists
        ? GlobalSettingsModel.fromMap(settingsDoc.data()!)
        : GlobalSettingsModel(bonusPercentR1: 0, minPayout: 5000000);

    final salesSnapshot = await db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .where('payment_status', isEqualTo: SaleModel.statusComplete)
        .get();

    int totalSales = 0;
    int totalCommission = 0;
    int totalPulsa = 0;
    int commissionBalanceIncrement = 0;

    for (var doc in salesSnapshot.docs) {
      final data = doc.data();
      totalSales++;

      double commissionAmount = (data['commission_amount'] ?? 0).toDouble();

      // Proactive Fix: If transaction was made under general category (0%)
      // but user is now Reseller/Distributor, recalculate the commission!
      if (commissionAmount == 0 && marketingCategory != null) {
        final double totalPrice = (data['total_price'] ?? 0).toDouble();
        double percent = 0;
        if (marketingCategory == 'reseller') {
          percent = settings.resellerCommissionPercent;
        } else if (marketingCategory == 'distributor') {
          percent = settings.distributorCommissionPercent;
        }

        if (percent > 0) {
          commissionAmount = totalPrice * (percent / 100);
          final int commInt = commissionAmount.toInt();

          // 1. Update the transaction in Firestore
          await doc.reference.update({
            'commission_amount': commissionAmount,
            'commission_earned': commInt,
            'details.marketing_category': marketingCategory,
            'details.commission_percentage': percent,
            'details.discount_amount': commissionAmount,
            'details.netto': totalPrice - commissionAmount,
          });

          // 2. Check if a wallet history was ever created for this transaction
          final existingHistory = await db
              .collection('wallet_history')
              .where('related_ref_id', isEqualTo: doc.id)
              .where('type', isEqualTo: 'COMMISSION_IN')
              .limit(1)
              .get();

          if (existingHistory.docs.isEmpty) {
            // 3. Create wallet history
            final commHistoryRef = db.collection('wallet_history').doc();
            final commHistory = WalletHistoryModel(
              id: commHistoryRef.id,
              userId: userId,
              type: 'COMMISSION_IN',
              amount: commInt,
              description:
                  'Komisi Penjualan (Koreksi): ${(data['details'] as Map?)?['product_name'] ?? "Item"}',
              relatedRefId: doc.id,
              createdAt: DateTime.now(),
            );
            await commHistoryRef.set(commHistory.toMap());

            // 4. Record the balance increment
            commissionBalanceIncrement += commInt;
          }
        }
      }

      totalCommission += commissionAmount.toInt();
      totalPulsa += ((data['pulsa_bonus_amount'] ?? 0) as num).toInt();
    }

    final Map<String, dynamic> userUpdates = {
      'total_sales_count': totalSales,
      'total_commission_earned': totalCommission,
      'total_pulsa_earned': totalPulsa,
    };

    if (commissionBalanceIncrement > 0) {
      userUpdates['commission_balance'] = FieldValue.increment(
        commissionBalanceIncrement,
      );
    }

    await userRef.update(userUpdates);
  }
}
