import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/wallet_history_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class WalletService extends BaseFirestoreService {
  WalletService({super.firestore});
  // Claims
  Stream<List<ClaimModel>> getUserClaims(String userId) {
    return db
        .collection('claims')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<ClaimModel>> getPendingClaims() {
    return db
        .collection('claims')
        .where('status', isEqualTo: ClaimModel.statusPending)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<ClaimModel>> getClaimHistory() {
    return db
        .collection('claims')
        .where('status', isNotEqualTo: ClaimModel.statusPending)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<ClaimModel?> getClaim(String claimId) async {
    final doc = await db.collection('claims').doc(claimId).get();
    if (doc.exists) {
      return ClaimModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> requestClaim(ClaimModel claim) async {
    final userRef = db.collection('users').doc(claim.userId);
    final claimRef = db.collection('claims').doc();
    final historyRef = db.collection('wallet_history').doc();

    await db.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception('User not found');

      final commBalance = ((userDoc.data()?['commission_balance'] ?? 0) as num).toInt();
      final markupBalance = ((userDoc.data()?['markup_balance'] ?? 0) as num).toInt();
      final pulsaBalance = ((userDoc.data()?['pulsa_balance'] ?? 0) as num).toInt();

      int deductedCommission = 0;
      int deductedMarkup = 0;

      if (claim.type == ClaimModel.typePulsa) {
        if (pulsaBalance < claim.amount) {
          throw Exception('Saldo pulsa tidak cukup');
        }

        transaction.update(userRef, {
          'pulsa_balance': FieldValue.increment(-claim.amount),
        });
      } else {
        final totalCash = commBalance + markupBalance;
        if (totalCash < claim.amount) {
          throw Exception('Saldo tunai tidak cukup');
        }

        int remaining = claim.amount;

        if (commBalance > 0) {
          final toDeduct = remaining > commBalance ? commBalance : remaining;
          deductedCommission = toDeduct;
          transaction.update(userRef, {
            'commission_balance': FieldValue.increment(-toDeduct),
          });
          remaining -= toDeduct;
        }

        if (remaining > 0) {
          deductedMarkup = remaining;
          transaction.update(userRef, {
            'markup_balance': FieldValue.increment(-remaining),
          });
        }
      }

      final claimMap = claim.toMap();
      claimMap['deducted_commission'] = deductedCommission;
      claimMap['deducted_markup'] = deductedMarkup;

      transaction.set(claimRef, claimMap);

      final history = WalletHistoryModel(
        id: historyRef.id,
        userId: claim.userId,
        type: 'CLAIM_OUT',
        amount: claim.amount,
        description: 'Claim request (${claim.type})',
        relatedRefId: claimRef.id,
        createdAt: DateTime.now(),
      );
      transaction.set(historyRef, history.toMap());
    });

    return claimRef.id;
  }

  Future<void> approveClaim(String claimId) {
    return db.collection('claims').doc(claimId).update({
      'status': ClaimModel.statusPaid,
    });
  }

  Future<void> rejectClaim(ClaimModel claim) async {
    final userRef = db.collection('users').doc(claim.userId);
    final claimRef = db.collection('claims').doc(claim.id);
    final historyRef = db.collection('wallet_history').doc();

    return db.runTransaction((transaction) async {
      if (claim.type == ClaimModel.typePulsa) {
        transaction.update(userRef, {
          'pulsa_balance': FieldValue.increment(claim.amount),
        });
      } else {
        if (claim.deductedCommission > 0) {
          transaction.update(userRef, {
            'commission_balance': FieldValue.increment(
              claim.deductedCommission,
            ),
          });
        }
        if (claim.deductedMarkup > 0) {
          transaction.update(userRef, {
            'markup_balance': FieldValue.increment(claim.deductedMarkup),
          });
        }

        if (claim.deductedCommission == 0 &&
            claim.deductedMarkup == 0 &&
            claim.amount > 0) {
          transaction.update(userRef, {
            'commission_balance': FieldValue.increment(claim.amount),
          });
        }
      }

      transaction.update(claimRef, {'status': ClaimModel.statusRejected});

      final history = WalletHistoryModel(
        id: historyRef.id,
        userId: claim.userId,
        type: 'REFUND',
        amount: claim.amount,
        description: 'Claim rejected refund',
        relatedRefId: claim.id,
        createdAt: DateTime.now(),
      );
      transaction.set(historyRef, history.toMap());
    });
  }
}
