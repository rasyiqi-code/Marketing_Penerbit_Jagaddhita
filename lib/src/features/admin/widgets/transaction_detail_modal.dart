import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sale_detail_view.dart';

class TransactionDetailModal extends StatelessWidget {
  final SaleModel sale;

  const TransactionDetailModal({super.key, required this.sale});

  static void show(BuildContext context, SaleModel sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SaleDetailView(sale: sale, mode: SaleDetailMode.admin);
  }
}

