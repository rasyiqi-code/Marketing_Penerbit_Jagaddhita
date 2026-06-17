import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/async_snapshot_widget.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/transaction/transaction_detail_modal.dart';
import 'package:provider/provider.dart';

class AdminRecentTransactionsList extends StatelessWidget {
  const AdminRecentTransactionsList({super.key});

  void _showSaleDetailDialog(BuildContext context, SaleModel sale) {
    TransactionDetailModal.show(context, sale);
  }

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context, listen: false);
    return StreamBuilder<List<SaleModel>>(
      stream: salesService.getSales(limit: 5),
      builder: (context, snapshot) => AsyncSnapshotWidget<List<SaleModel>>(
        snapshot: snapshot,
        isEmpty: (data) => data.isEmpty,
        emptyWidget: const Text('Belum ada transaksi baru.'),
        builder: (context, sales) {
          return Column(
            children: sales.map((sale) {
              final isLunas = sale.paymentStatus == 'LUNAS';
              return InkWell(
                onTap: () => _showSaleDetailDialog(context, sale),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isLunas ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: isLunas ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale.details['product_name'] ?? 'Product',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sale.details['buyer_name'] ?? 'Buyer',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sale.paymentStatus == SaleModel.statusComplete
                              ? Colors.purple[50]
                              : (isLunas ? Colors.green[50] : Colors.orange[50]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sale.paymentStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: sale.paymentStatus == SaleModel.statusComplete
                                ? Colors.purple
                                : (isLunas ? Colors.green : Colors.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
