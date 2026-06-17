import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final AppNotificationService _notificationService;
  final NotificationService _localNotifications;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  StreamSubscription? _subscription;
  String? _currentUserId;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationController(this._notificationService, this._localNotifications);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void listenToNotifications(String userId, {bool isAdmin = false}) {
    // Avoid re-subscribing if same user/role
    if (_currentUserId == userId && _subscription != null) return;

    _subscription?.cancel();
    _currentUserId = userId;

    Stream<List<NotificationModel>> stream;
    if (isAdmin) {
      stream = _notificationService.getAdminNotifications();
    } else {
      stream = _notificationService.getUserNotifications(userId);
      // Run cleanup once on start (optimistic, don't await)
      _notificationService.cleanupOldNotifications(userId);
    }

    _subscription = stream.listen((newList) {
      // Check for new notifications to trigger local alert
      // Strategy: Use top item creation time to detect new ones efficiently?
      // Or diff IDs.
      if (newList.isNotEmpty && _notifications.isNotEmpty) {
        // Simple check: if latest item in new list is newer than latest in old list
        // and not in old list.
        final latestNew = newList.first;
        final alreadyHasIt = _notifications.any((n) => n.id == latestNew.id);

        if (!alreadyHasIt) {
          // It's a new notification!
          _localNotifications.showNotification(
            id: latestNew.hashCode,
            title: latestNew.title,
            body: latestNew.body,
            payload: latestNew.relatedId,
          );
        }
      } else if (newList.isNotEmpty && _notifications.isEmpty) {
        // Initial load? Don't spam. But if app was closed and opened?
        // Maybe check isRead?
        // Let's only notify for UNREAD items on first load?
        // Or honestly, just silent on first load to avoid spamming user with 50 alerts.
      }

      _notifications = newList;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    final oldNotifications = List<NotificationModel>.from(_notifications);
    if (index != -1) {
      final oldNotif = _notifications[index];
      _notifications[index] = NotificationModel(
        id: oldNotif.id,
        title: oldNotif.title,
        body: oldNotif.body,
        type: oldNotif.type,
        recipientId: oldNotif.recipientId,
        relatedId: oldNotif.relatedId,
        isRead: true,
        createdAt: oldNotif.createdAt,
      );
      notifyListeners();
    }
    try {
      await _notificationService.markNotificationAsRead(notificationId);
    } catch (e) {
      _notifications = oldNotifications;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final oldNotifications = List<NotificationModel>.from(_notifications);
    _notifications = _notifications.map((n) {
      if (notificationIds.contains(n.id)) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          recipientId: n.recipientId,
          relatedId: n.relatedId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    notifyListeners();

    try {
      await _notificationService.markNotificationsAsRead(notificationIds);
    } catch (e) {
      _notifications = oldNotifications;
      notifyListeners();
      rethrow;
    }
  }
}
