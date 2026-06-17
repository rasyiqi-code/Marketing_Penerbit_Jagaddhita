import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/empty_state_widget.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/controllers/notification_controller.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/services/notification_tap_handler.dart';
import 'package:provider/provider.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NotificationController>(context);
    final notifications = controller.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.mark_as_unread_rounded),
              tooltip: 'Tandai semua dibaca',
              onPressed: () {
                final unreadIds =
                    notifications.where((n) => !n.isRead).map((n) => n.id).toList();
                controller.markAllAsRead(unreadIds);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: notifications.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.notifications_off_outlined,
                title: 'Tidak Ada Notifikasi',
                message: 'Semua kabar terbaru akan muncul di sini saat tersedia.',
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationTile(
                    context,
                    notification,
                    controller,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationModel.typeSuccess:
        iconColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case NotificationModel.typeWarning:
        iconColor = Colors.orange;
        iconData = Icons.warning_amber_rounded;
        break;
      case NotificationModel.typeError:
        iconColor = Colors.red;
        iconData = Icons.error_outline;
        break;
      default:
        iconColor = Colors.blue;
        iconData = Icons.info_outline;
    }

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : Colors.blue.withValues(alpha: 0.05),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.outfit(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () => NotificationTapHandler.handleTap(context, notification, controller),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (notificationDate == yesterday) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE, HH:mm', 'id_ID').format(date);
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    }
  }
}

