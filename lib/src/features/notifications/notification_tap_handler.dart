import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/notification_controller.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sale_detail_dialog.dart';
import 'package:provider/provider.dart';

/// Helper class to handle tap gestures on notifications, fetching related data,
/// and performing navigation or showing appropriate dialogs.
class NotificationTapHandler {
  static Future<void> handleTap(
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

    // Show loading dialog
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
        // Fetch Claim
        final claim = await walletService.getClaim(notification.relatedId!);

        if (context.mounted) Navigator.pop(context); // Close loading

        if (claim != null && context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Detail Info'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${claim.status}'),
                  Text('Amount: Rp ${claim.amount}'),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(claim.createdAt)}',
                  ),
                  if (claim.status == 'REJECTED') const Text('Refunded to balance.'),
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
}
