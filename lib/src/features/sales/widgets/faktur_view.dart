import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

class FakturView extends StatelessWidget {
  final SaleModel sale;

  const FakturView({super.key, required this.sale});

  // Helper: generates formatted invoice text for clipboard/sharing
  String _generateInvoiceText() {
    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(sale.createdAt);
    final statusStr = sale.paymentStatus.toUpperCase();
    final itemsNames = sale.productNames;
    final itemsPrices = sale.productPrices;
    final itemsQuantities = sale.productQuantities;

    final buffer = StringBuffer();
    buffer.writeln('------------------------------------------');
    buffer.writeln('          FAKTUR PENJUALAN BUKU           ');
    buffer.writeln('          PENERBIT JAGADDHITA             ');
    buffer.writeln('------------------------------------------');
    buffer.writeln('ID Transaksi : ${sale.id.toUpperCase()}');
    buffer.writeln('Tanggal      : $dateStr');
    buffer.writeln('Status       : $statusStr');
    buffer.writeln('Agen         : ${sale.details['agent_name'] ?? 'Unknown'}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('PELANGGAN:');
    buffer.writeln('Nama         : ${sale.customerName}');
    buffer.writeln('Nomor HP     : ${sale.customerPhone}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('RINCIAN ITEM:');

    for (int i = 0; i < itemsNames.length; i++) {
      final name = itemsNames[i];
      final price = itemsPrices.length > i ? itemsPrices[i] : 0.0;
      final qty = itemsQuantities.length > i ? itemsQuantities[i] : 1;
      final subtotal = price * qty;
      buffer.writeln('- $name');
      buffer.writeln(
        '  $qty eks x ${AppFormatters.currency(price)} = ${AppFormatters.currency(subtotal)}',
      );
    }

    final sisa = sale.totalPrice - sale.paidAmount;
    buffer.writeln('------------------------------------------');
    buffer.writeln('Total Bruto  : ${AppFormatters.currency(sale.totalPrice)}');
    buffer.writeln(
      'Diskon/Komisi: ${AppFormatters.currency(sale.commissionAmount)}',
    );
    buffer.writeln(
      'Total Netto  : ${AppFormatters.currency(sale.totalPrice - sale.commissionAmount)}',
    );
    buffer.writeln('Jumlah Bayar : ${AppFormatters.currency(sale.paidAmount)}');
    buffer.writeln('Sisa Tagihan : ${AppFormatters.currency(sisa)}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('Terima kasih telah berbelanja!');
    buffer.writeln('Penerbit Jagaddhita - Edukasi Bangsa');

    return buffer.toString();
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _generateInvoiceText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Faktur berhasil disalin ke Clipboard!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareInvoice() {
    SharePlus.instance.share(
      ShareParams(
        text: _generateInvoiceText(),
        subject: 'Faktur Penjualan Penerbit Jagaddhita',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(sale.createdAt);
    final isLunas = sale.paymentStatus.toUpperCase() == 'LUNAS';
    final isComplete = sale.paymentStatus.toUpperCase() == 'COMPLETE';
    final isDp = sale.paymentStatus.toUpperCase() == 'DP';
    final isPending = sale.paymentStatus.toUpperCase() == 'PENDING';

    final itemsNames = sale.productNames;
    final itemsPrices = sale.productPrices;
    final itemsQuantities = sale.productQuantities;

    Color stampColor;
    String stampText;
    if (isComplete || isLunas) {
      stampColor = Colors.green;
      stampText = 'PAID / LUNAS';
    } else if (isDp) {
      stampColor = Colors.orange;
      stampText = 'DP / SEBAGIAN';
    } else if (isPending) {
      stampColor = Colors.grey;
      stampText = 'PENDING';
    } else {
      stampColor = Colors.red;
      stampText = sale.paymentStatus.toUpperCase();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Faktur Transaksi',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Row(
            children: [
              Expanded(
                child: Container(height: 4, color: AppTheme.secondaryColor),
              ),
              Expanded(child: Container(height: 4, color: Colors.white)),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // White Invoice sheet
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher Info & Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penerbit Jagaddhita',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            'Edukasi Bangsa',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'FAKTUR',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Metadata Info Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _metaText('No. Faktur', sale.id.toUpperCase()),
                            _metaText('Tanggal', dateStr),
                            _metaText(
                              'Agen',
                              sale.details['agent_name'] ?? 'Unknown',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PELANGGAN / BUYER:',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sale.customerName,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sale.customerPhone,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Table header
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Judul Buku / Item',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Harga',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Body
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsNames.length,
                    separatorBuilder: (ctx, idx) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final name = itemsNames[idx];
                      final price = itemsPrices.length > idx
                          ? itemsPrices[idx]
                          : 0.0;
                      final qty = itemsQuantities.length > idx
                          ? itemsQuantities[idx]
                          : 1;
                      final subtotal = price * qty;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                name,
                                style: GoogleFonts.outfit(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$qty eks',
                                style: GoogleFonts.outfit(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppFormatters.currency(price),
                                style: GoogleFonts.outfit(fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppFormatters.currency(subtotal),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 2),
                  const SizedBox(height: 12),

                  // Receipt Calculations & Paid Stamp Overlay
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // Stamp
                      Transform.rotate(
                        angle: -0.2,
                        child: Opacity(
                          opacity: 0.15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: stampColor, width: 3),
                            ),
                            child: Text(
                              stampText,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: stampColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Summary Details Row
                      Column(
                        children: [
                          _summaryLine('Total Bruto', sale.totalPrice),
                          _summaryLine(
                            'Diskon / Komisi Agen',
                            sale.commissionAmount,
                            isDiscount: true,
                          ),
                          _summaryLine(
                            'Total Netto',
                            sale.totalPrice - sale.commissionAmount,
                          ),
                          _summaryLine(
                            'Jumlah Dibayar',
                            sale.paidAmount,
                            isHighlighted: true,
                          ),
                          const Divider(),
                          _summaryLine(
                            'Sisa Tagihan (Balance Due)',
                            sale.totalPrice - sale.paidAmount,
                            isBold: true,
                            boldColor: stampColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share / Action button row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 2,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(
                      'Salin Faktur',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _shareInvoice,
                    icon: const Icon(Icons.share_rounded),
                    label: Text(
                      'Bagikan Faktur',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _metaText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isHighlighted = false,
    bool isBold = false,
    Color? boldColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppTheme.primaryColor : Colors.grey[700],
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}${AppFormatters.currency(amount)}',
            style: GoogleFonts.outfit(
              fontSize: isBold ? 14 : 12,
              fontWeight: (isBold || isHighlighted)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isBold
                  ? (boldColor ?? Colors.black)
                  : (isHighlighted ? AppTheme.primaryColor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
