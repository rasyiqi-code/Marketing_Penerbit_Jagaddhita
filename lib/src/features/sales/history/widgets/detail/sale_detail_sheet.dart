import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sale_detail_view.dart';

/// Full-detail bottom sheet untuk satu transaksi penjualan.
void showSaleDetailModal(BuildContext context, SaleModel sale) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SaleDetailSheet(sale: sale),
  );
}

class SaleDetailSheet extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailSheet({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return SaleDetailView(sale: sale, mode: SaleDetailMode.sales);
  }
}

