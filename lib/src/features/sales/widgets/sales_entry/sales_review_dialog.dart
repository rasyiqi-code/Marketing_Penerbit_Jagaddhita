import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

class SalesReviewDialog extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<ProductModel> selectedProducts;
  final Map<String, int> selectedProductQuantities;
  final String paymentStatus;
  final double bruto;
  final double commissionAmount;
  final double netto;
  final String dpAmountText;

  const SalesReviewDialog({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.selectedProducts,
    required this.selectedProductQuantities,
    required this.paymentStatus,
    required this.bruto,
    required this.commissionAmount,
    required this.netto,
    required this.dpAmountText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Review Order',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customer:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(customerName, style: GoogleFonts.outfit(fontSize: 13)),
            Text(customerPhone, style: GoogleFonts.outfit(fontSize: 13)),
            Text(customerAddress, style: GoogleFonts.outfit(fontSize: 13)),
            const SizedBox(height: 12),
            Text('Produk Dipesan:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            ...selectedProducts.map((p) {
              final q = selectedProductQuantities[p.id] ?? 1;
              return Text('- ${p.name} (x$q)', style: GoogleFonts.outfit(fontSize: 13));
            }),
            const SizedBox(height: 12),
            Text('Detail Pembayaran:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Tipe Bayar: $paymentStatus', style: GoogleFonts.outfit(fontSize: 13)),
            Text('Total Bruto: ${AppFormatters.currency(bruto)}', style: GoogleFonts.outfit(fontSize: 13)),
            Text('Komisi: ${AppFormatters.currency(commissionAmount)}', style: GoogleFonts.outfit(fontSize: 13)),
            Text('Netto: ${AppFormatters.currency(netto)}', style: GoogleFonts.outfit(fontSize: 13)),
            if (paymentStatus == 'DP')
              Text('Jumlah DP: Rp $dpAmountText', style: GoogleFonts.outfit(fontSize: 13)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Kirim Order',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}
