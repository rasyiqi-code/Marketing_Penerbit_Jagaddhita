import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/wallet_history_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';

class SalesService extends BaseFirestoreService {
  final AppNotificationService _notificationService;

  SalesService({super.firestore})
      : _notificationService = AppNotificationService(firestore: firestore);

  Future<void> addSale(SaleModel sale) {
    if (sale.paymentStatus != SaleModel.statusComplete) {
      return db.collection('sales').add(sale.toMap());
    }

    final saleRef = db.collection('sales').doc();
    final userRef = db.collection('users').doc(sale.userId);

    return db.runTransaction((transaction) async {
      transaction.set(saleRef, sale.toMap());

      if (sale.commissionAmount > 0) {
        transaction.update(userRef, {
          'commission_balance': FieldValue.increment(
            sale.commissionAmount.toInt(),
          ),
        });

        final commHistoryRef = db.collection('wallet_history').doc();
        final commHistory = WalletHistoryModel(
          id: commHistoryRef.id,
          userId: sale.userId,
          type: 'COMMISSION_IN',
          amount: sale.commissionAmount.toInt(),
          description:
              'Komisi Penjualan: ${sale.details['product_name'] ?? "Item"}',
          relatedRefId: saleRef.id,
          createdAt: DateTime.now(),
        );
        transaction.set(commHistoryRef, commHistory.toMap());
      }

      if (sale.pulsaBonusAmount > 0) {
        transaction.update(userRef, {
          'pulsa_balance': FieldValue.increment(sale.pulsaBonusAmount.toInt()),
        });

        final pulsaHistoryRef = db.collection('wallet_history').doc();
        final pulsaHistory = WalletHistoryModel(
          id: pulsaHistoryRef.id,
          userId: sale.userId,
          type: 'PULSA_IN',
          amount: sale.pulsaBonusAmount.toInt(),
          description: 'Bonus Pulsa: ${sale.details['product_name'] ?? "Item"}',
          relatedRefId: saleRef.id,
          createdAt: DateTime.now(),
        );
        transaction.set(pulsaHistoryRef, pulsaHistory.toMap());
      }

      if ((sale.totalMarkup ?? 0) > 0) {
        transaction.update(userRef, {
          'markup_balance': FieldValue.increment(sale.totalMarkup ?? 0),
        });

        final markupHistoryRef = db.collection('wallet_history').doc();
        final markupHistory = WalletHistoryModel(
          id: markupHistoryRef.id,
          userId: sale.userId,
          type: 'MARKUP_IN',
          amount: sale.totalMarkup ?? 0,
          description:
              'Markup Penjualan: ${sale.details['product_name'] ?? "Item"}',
          relatedRefId: saleRef.id,
          createdAt: DateTime.now(),
        );
        transaction.set(markupHistoryRef, markupHistory.toMap());
      }

      transaction.update(userRef, {
        'total_sales_count': FieldValue.increment(1),
        'total_commission_earned': FieldValue.increment(
          sale.commissionAmount.toInt(),
        ),
        'total_pulsa_earned': FieldValue.increment(
          sale.pulsaBonusAmount.toInt(),
        ),
      });
    });
  }

  Future<void> updateSaleStatus(
    SaleModel sale,
    String newStatus, {
    String? note,
    String actor = 'Admin',
    Map<String, dynamic>? extraData,
  }) async {
    final saleRef = db.collection('sales').doc(sale.id);
    final userRef = db.collection('users').doc(sale.userId);

    final historyItem = SaleHistoryItem(
      status: newStatus,
      note: note,
      timestamp: DateTime.now(),
      actor: actor,
    );

    return db.runTransaction((transaction) async {
      final saleDoc = await transaction.get(saleRef);
      if (!saleDoc.exists) throw Exception("Sale does not exist!");
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception("User does not exist!");

      final currentStatus = saleDoc.data()?['payment_status'];

      if (newStatus == SaleModel.statusComplete &&
          currentStatus != SaleModel.statusComplete) {
        _applyCompleteTransaction(
          transaction,
          saleRef: saleRef,
          userRef: userRef,
          userDoc: userDoc,
          sale: sale,
          historyItem: historyItem,
          extraData: extraData,
        );
      } else if (currentStatus == SaleModel.statusComplete &&
          newStatus != SaleModel.statusComplete) {
        _applyReversalTransaction(
          transaction,
          saleRef: saleRef,
          userRef: userRef,
          saleDoc: saleDoc,
          newStatus: newStatus,
          historyItem: historyItem,
          extraData: extraData,
        );
      } else {
        final updateMap = {
          'payment_status': newStatus,
          'history': FieldValue.arrayUnion([historyItem.toMap()]),
          ...?extraData,
        };
        transaction.update(saleRef, updateMap);
      }
    }).then((_) {
      if (newStatus == SaleModel.statusComplete &&
          note != 'NOTIFICATION_SENT') {
        _sendCompleteNotification(sale);
      }
    });
  }

  void _applyCompleteTransaction(
    Transaction transaction, {
    required DocumentReference saleRef,
    required DocumentReference userRef,
    required DocumentSnapshot userDoc,
    required SaleModel sale,
    required SaleHistoryItem historyItem,
    required Map<String, dynamic>? extraData,
  }) {
    double finalBonusAmount = sale.pulsaBonusAmount;
    final Map<String, dynamic> userUpdates = {};

    if (finalBonusAmount > 0) {
      final data = userDoc.data() as Map<String, dynamic>?;
      final lastBonusTimestamp = data?['last_pulsa_bonus_at'];
      DateTime? lastBonus;
      if (lastBonusTimestamp is Timestamp) {
        lastBonus = lastBonusTimestamp.toDate();
      }

      final now = DateTime.now();
      if (lastBonus != null &&
          lastBonus.year == now.year &&
          lastBonus.month == now.month) {
        finalBonusAmount = 0;
      } else {
        userUpdates['last_pulsa_bonus_at'] = FieldValue.serverTimestamp();
      }
    }

    final updateMap = {
      'payment_status': SaleModel.statusComplete,
      'pulsa_bonus_amount': finalBonusAmount,
      'history': FieldValue.arrayUnion([historyItem.toMap()]),
      ...?extraData,
    };
    transaction.update(saleRef, updateMap);

    if (sale.commissionAmount > 0) {
      userUpdates['commission_balance'] = FieldValue.increment(
        sale.commissionAmount.toInt(),
      );

      final commHistoryRef = db.collection('wallet_history').doc();
      final commHistory = WalletHistoryModel(
        id: commHistoryRef.id,
        userId: sale.userId,
        type: 'COMMISSION_IN',
        amount: sale.commissionAmount.toInt(),
        description:
            'Komisi Penjualan: ${sale.details['product_name'] ?? "Item"}',
        relatedRefId: sale.id,
        createdAt: DateTime.now(),
      );
      transaction.set(commHistoryRef, commHistory.toMap());
    }

    if (finalBonusAmount > 0) {
      userUpdates['pulsa_balance'] = FieldValue.increment(
        finalBonusAmount.toInt(),
      );

      final pulsaHistoryRef = db.collection('wallet_history').doc();
      final pulsaHistory = WalletHistoryModel(
        id: pulsaHistoryRef.id,
        userId: sale.userId,
        type: 'PULSA_IN',
        amount: finalBonusAmount.toInt(),
        description: 'Bonus Pulsa: ${sale.details['product_name'] ?? "Item"}',
        relatedRefId: sale.id,
        createdAt: DateTime.now(),
      );
      transaction.set(pulsaHistoryRef, pulsaHistory.toMap());
    }

    if ((sale.totalMarkup ?? 0) > 0) {
      userUpdates['markup_balance'] = FieldValue.increment(
        sale.totalMarkup ?? 0,
      );

      final markupHistoryRef = db.collection('wallet_history').doc();
      final markupHistory = WalletHistoryModel(
        id: markupHistoryRef.id,
        userId: sale.userId,
        type: 'MARKUP_IN',
        amount: sale.totalMarkup ?? 0,
        description:
            'Markup Penjualan: ${sale.details['product_name'] ?? "Item"}',
        relatedRefId: sale.id,
        createdAt: DateTime.now(),
      );
      transaction.set(markupHistoryRef, markupHistory.toMap());
    }

    userUpdates['total_sales_count'] = FieldValue.increment(1);
    userUpdates['total_commission_earned'] = FieldValue.increment(
      sale.commissionAmount.toInt(),
    );
    userUpdates['total_pulsa_earned'] = FieldValue.increment(
      finalBonusAmount.toInt(),
    );

    if (userUpdates.isNotEmpty) {
      transaction.update(userRef, userUpdates);
    }
  }

  void _applyReversalTransaction(
    Transaction transaction, {
    required DocumentReference saleRef,
    required DocumentReference userRef,
    required DocumentSnapshot saleDoc,
    required String newStatus,
    required SaleHistoryItem historyItem,
    required Map<String, dynamic>? extraData,
  }) {
    final saleData = saleDoc.data() as Map<String, dynamic>?;
    final double commissionAmount = (saleData?['commission_amount'] ?? 0.0).toDouble();
    final double pulsaBonusAmount = (saleData?['pulsa_bonus_amount'] ?? 0.0).toDouble();
    final int totalMarkup = (saleData?['total_markup'] ?? 0);
    final String userId = saleData?['user_id'] ?? '';
    final String saleId = saleDoc.id;

    final updateMap = {
      'payment_status': newStatus,
      'history': FieldValue.arrayUnion([historyItem.toMap()]),
      ...?extraData,
    };
    transaction.update(saleRef, updateMap);

    if (commissionAmount > 0) {
      transaction.update(userRef, {
        'commission_balance': FieldValue.increment(
          -commissionAmount.toInt(),
        ),
      });
      final commHistoryRef = db.collection('wallet_history').doc();
      transaction.set(
        commHistoryRef,
        WalletHistoryModel(
          id: commHistoryRef.id,
          userId: userId,
          type: 'COMMISSION_OUT',
          amount: commissionAmount.toInt(),
          description: 'Reversal: Status changed from COMPLETE to $newStatus',
          relatedRefId: saleId,
          createdAt: DateTime.now(),
        ).toMap(),
      );
    }

    if (pulsaBonusAmount > 0) {
      transaction.update(userRef, {
        'pulsa_balance': FieldValue.increment(-pulsaBonusAmount.toInt()),
        'last_pulsa_bonus_at': FieldValue.delete(),
      });
      final pulsaHistoryRef = db.collection('wallet_history').doc();
      transaction.set(
        pulsaHistoryRef,
        WalletHistoryModel(
          id: pulsaHistoryRef.id,
          userId: userId,
          type: 'PULSA_OUT',
          amount: pulsaBonusAmount.toInt(),
          description: 'Reversal: Status changed from COMPLETE to $newStatus',
          relatedRefId: saleId,
          createdAt: DateTime.now(),
        ).toMap(),
      );
    }

    if (totalMarkup > 0) {
      transaction.update(userRef, {
        'markup_balance': FieldValue.increment(-totalMarkup),
      });
      final markupHistoryRef = db.collection('wallet_history').doc();
      transaction.set(
        markupHistoryRef,
        WalletHistoryModel(
          id: markupHistoryRef.id,
          userId: userId,
          type: 'MARKUP_OUT',
          amount: totalMarkup,
          description: 'Reversal: Status changed from COMPLETE to $newStatus',
          relatedRefId: saleId,
          createdAt: DateTime.now(),
        ).toMap(),
      );
    }

    transaction.update(userRef, {
      'total_sales_count': FieldValue.increment(-1),
      'total_commission_earned': FieldValue.increment(
        -commissionAmount.toInt(),
      ),
      'total_pulsa_earned': FieldValue.increment(
        -pulsaBonusAmount.toInt(),
      ),
    });
  }

  void _sendCompleteNotification(SaleModel sale) {
    final double comm = sale.commissionAmount;
    final double markup = (sale.totalMarkup ?? 0).toDouble();
    final double earned = comm + markup;

    if (earned > 0) {
      String bodyMsg =
          'Selamat! Penjualan "${sale.details['product_name']}" Selesai.';

      if (comm > 0) {
        bodyMsg +=
            '\nKomisi: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(comm)}';
      }
      if (markup > 0) {
        bodyMsg +=
            '\nMarkup: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(markup)}';
      }
      final double bonus = sale.pulsaBonusAmount;
      if (bonus > 0) {
        bodyMsg +=
            '\nBonus Pulsa: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(bonus)}';
      }

      bodyMsg += '\nTelah masuk ke saldo Anda.';

      _notificationService.sendNotification(
        NotificationModel(
          id: '',
          title: 'Penjualan Selesai! 🎉',
          body: bodyMsg,
          type: NotificationModel.typeSuccess,
          recipientId: sale.userId,
          relatedId: sale.id,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Stream<List<SaleModel>> getUserSales(String userId, {int? limit}) {
    Query query = db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                SaleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  Future<int> getUserBonusCountThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final snapshot = await db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
        .where('created_at', isLessThan: nextMonth)
        .get();

    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final pb = (data['pulsa_bonus_amount'] ?? 0) as num;
      final status = data['payment_status'];

      if (pb > 0 && status != SaleModel.statusCanceled) {
        count++;
      }
    }
    return count;
  }

  Future<int> getUserCompletedSalesCount(String userId) async {
    final snapshot = await db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .where('payment_status', isEqualTo: SaleModel.statusComplete)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<Map<String, num>> getUserSalesStatsThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final snapshot = await db
        .collection('sales')
        .where('user_id', isEqualTo: userId)
        .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
        .where('created_at', isLessThan: nextMonth)
        .get();

    int count = 0;
    double total = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['payment_status'] != SaleModel.statusCanceled) {
        count++;
        total += (data['total_price'] ?? 0) as num;
      }
    }
    return {'count': count, 'total': total};
  }

  Future<SaleModel?> getSale(String saleId) async {
    final doc = await db.collection('sales').doc(saleId).get();
    if (doc.exists) {
      return SaleModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<SaleModel>> getSales({
    int? houseType,
    String? status,
    int? limit,
  }) {
    Query query = db.collection('sales');

    if (houseType != null) {
      query = query.where('details.house_type', isEqualTo: houseType);
    }

    if (status != null) {
      query = query.where('payment_status', isEqualTo: status);
    }

    query = query.orderBy('created_at', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (s) => s.docs
          .map((d) => SaleModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList(),
    );
  }
}
