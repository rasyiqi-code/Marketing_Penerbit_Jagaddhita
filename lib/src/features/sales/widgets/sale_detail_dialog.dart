import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sale_detail_view.dart';

class SaleDetailDialog extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return SaleDetailView(sale: sale, mode: SaleDetailMode.general);
  }
}

