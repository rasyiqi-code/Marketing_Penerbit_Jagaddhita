import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/sales_history_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/async_snapshot_widget.dart';
import 'package:provider/provider.dart';

class RecentSalesList extends StatelessWidget {
  final String userId;

  const RecentSalesList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktifitas Terkini',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<SaleModel>>(
          stream: Provider.of<SalesService>(
            context,
            listen: false,
          ).getUserSales(userId),
          builder: (context, snapshot) => AsyncSnapshotWidget<List<SaleModel>>(
            snapshot: snapshot,
            isEmpty: (data) => data.isEmpty,
            emptyWidget: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  'Belum ada transaksi terbaru.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            builder: (context, sales) {
              final recentSales = sales.take(3).toList();

              return Column(
                children: recentSales.map((sale) {
                  final isComplete =
                      sale.paymentStatus == SaleModel.statusComplete;
                  final isLunas = sale.paymentStatus == SaleModel.statusLunas;
                  final isProblem = sale.paymentStatus == SaleModel.statusProblem;

                  Color statusColor;
                  IconData statusIcon;

                  if (isComplete) {
                    statusColor = Colors.blue;
                    statusIcon = Icons.check_circle;
                  } else if (isLunas) {
                    statusColor = Colors.green;
                    statusIcon = Icons.verified;
                  } else if (isProblem) {
                    statusColor = Colors.red;
                    statusIcon = Icons.warning_amber_rounded;
                  } else {
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time_filled;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.details['product_name'] ?? 'Produk',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppFormatters.currency(sale.totalPrice)} • ${sale.paymentStatus}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppFormatters.timeAgo(sale.createdAt),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
