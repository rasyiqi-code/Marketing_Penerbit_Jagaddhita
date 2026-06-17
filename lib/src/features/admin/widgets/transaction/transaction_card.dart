import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/transaction/transaction_detail_modal.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/transaction_update/transaction_update_dialog.dart';
import 'package:provider/provider.dart';

class TransactionCard extends StatelessWidget {
  final SaleModel sale;

  const TransactionCard({super.key, required this.sale});

  Future<void> _cancelTransaction(BuildContext context, SaleModel sale) async {
    try {
      final salesService = Provider.of<SalesService>(context, listen: false);
      final notificationService = Provider.of<FirestoreNotificationService>(context, listen: false);

      await salesService.updateSaleStatus(
        sale,
        SaleModel.statusCanceled,
        note: 'Dibatalkan oleh Admin via tombol Batalkan',
        actor: 'Admin',
      );

      final notification = NotificationModel(
        id: '',
        title: 'Transaksi Dibatalkan',
        body:
            'Transaksi #${sale.id.substring(0, 8).toUpperCase()} telah dibatalkan oleh Admin',
        type: NotificationModel.typeWarning,
        recipientId: sale.userId,
        relatedId: sale.id,
        createdAt: DateTime.now(),
      );

      await notificationService.sendNotification(notification);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dibatalkan')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isLunas = sale.paymentStatus == SaleModel.statusLunas;
    final isComplete = sale.paymentStatus == SaleModel.statusComplete;
    final isPending = sale.paymentStatus == SaleModel.statusPending;

    Color statusColor;
    Color textColor;
    if (isComplete || isLunas) {
      statusColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    } else if (isPending) {
      statusColor = AppTheme.accentColor;
      textColor = const Color(0xFFB8860B);
    } else {
      statusColor = AppTheme.secondaryColor;
      textColor = AppTheme.secondaryColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sleek left-edge patriot Red-White accent strip if transaction is Green (complete/lunas)
            if (isComplete || isLunas)
              SizedBox(
                width: 4,
                child: Column(
                  children: [
                    Expanded(child: Container(color: AppTheme.secondaryColor)), // Red top
                    Expanded(child: Container(color: Colors.white)), // White bottom
                  ],
                ),
              )
            else
              Container(width: 4, color: statusColor.withValues(alpha: 0.3)),

            Expanded(
              child: InkWell(
                onTap: () => TransactionDetailModal.show(context, sale),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Time & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              sale.paymentStatus,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Product Title
                      Text(
                        sale.details['product_name'] ?? '-',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Customer & Agent Details
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cust: ${sale.customerName} | Agent: ${sale.details['agent_name'] ?? sale.details['buyer_name'] ?? '-'}',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Pricing & Actions Compact Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Price',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                currencyFormat.format(sale.totalPrice),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Action buttons
                          if (!isComplete &&
                              sale.paymentStatus != SaleModel.statusCanceled &&
                              sale.paymentStatus != SaleModel.statusProblem)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _cancelTransaction(context, sale),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: Text(
                                    'Batalkan',
                                    style: GoogleFonts.outfit(color: AppTheme.secondaryColor, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed: () =>
                                      TransactionUpdateDialog.show(context, sale),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: Text(
                                    'Update',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
