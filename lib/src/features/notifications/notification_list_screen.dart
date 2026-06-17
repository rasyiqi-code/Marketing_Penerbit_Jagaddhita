import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/notification_controller.dart';

import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sale_detail_dialog.dart';
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
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: () {
                final unreadIds = notifications
                    .where((n) => !n.isRead)
                    .map((n) => n.id)
                    .toList();
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
            ? const _EmptyState(
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
        onTap: () => _handleNotificationTap(context, notification, controller),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) async {
    // 1. Mark as read
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }

    if (notification.relatedId == null) return;

    final salesService = Provider.of<SalesService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Determine Type based on Title/Body keywords
      final title = notification.title.toLowerCase();

      if (title.contains('transaksi') ||
          title.contains('penjualan') ||
          title.contains('bukti')) {
        // Fetch Sale
        final sale = await salesService.getSale(notification.relatedId!);

        if (context.mounted) Navigator.pop(context); // Close loading

        if (sale != null && context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SaleDetailDialog(sale: sale),
          );
        } else if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Data transaksi tidak ditemukan')),
          );
        }
      } else if (title.contains('withdraw') ||
          title.contains('pulsa') ||
          title.contains('claim') ||
          title.contains('permintaan')) {
        // Fetch Claim (Just check if exists for now, maybe show simple dialog)
        final claim = await walletService.getClaim(notification.relatedId!);

        if (context.mounted) Navigator.pop(context); // Close loading

        if (claim != null && context.mounted) {
          // For now, just show a simple dialog since we didn't extract ClaimDetail
          // Or just SnackBar saying "See Withdrawal History"
          // Ideally navigate to WithdrawalScreen history tab if possible
          // But showing a dialog is consistent.
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Detail Info'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${claim.status}'),
                  Text('Amount: Rp ${claim.amount}'),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(claim.createdAt)}',
                  ),
                  if (claim.status == 'REJECTED') Text('Refunded to balance.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Data claim tidak ditemukan')),
          );
        }
      } else {
        if (context.mounted) Navigator.pop(context); // Close loading
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.01),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
