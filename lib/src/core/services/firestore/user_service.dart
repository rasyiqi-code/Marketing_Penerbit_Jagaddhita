import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markating_kbm_app/src/core/models/user_model.dart';
import 'package:markating_kbm_app/src/core/models/sale_model.dart';
import 'package:markating_kbm_app/src/core/services/firestore/base_firestore_service.dart';

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

    final salesSnapshot = await db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .where('payment_status', isEqualTo: SaleModel.statusComplete)
        .get();

    int totalSales = 0;
    int totalCommission = 0;
    int totalPulsa = 0;

    for (var doc in salesSnapshot.docs) {
      final data = doc.data();
      totalSales++;
      totalCommission += (data['commission_amount'] ?? 0) as int;
      totalPulsa += (data['pulsa_bonus_amount'] ?? 0) as int;
    }

    await userRef.update({
      'total_sales_count': totalSales,
      'total_commission_earned': totalCommission,
      'total_pulsa_earned': totalPulsa,
    });
  }
}
