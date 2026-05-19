import 'package:flutter/foundation.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class AppNotificationService extends BaseFirestoreService {
  AppNotificationService({super.firestore});
  Future<void> sendNotification(NotificationModel notification) {
    return db.collection('notifications').add(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => NotificationModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<NotificationModel>> getAdminNotifications() {
    return db
        .collection('notifications')
        .where('recipientId', isEqualTo: 'role:admin')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => NotificationModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) {
    return db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> cleanupOldNotifications(String userId) async {
    final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));

    final snapshot = await db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('createdAt', isLessThan: cutoffDate)
        .limit(500)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final batch = db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint(
        'Cleaned up ${snapshot.docs.length} old notifications (older than 24h) for $userId',
      );
    }
  }
}
