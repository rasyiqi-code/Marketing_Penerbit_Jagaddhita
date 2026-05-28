import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

import 'faktur_printable_sheet.dart';
import '../utils/faktur_pdf_generator.dart';

class FakturView extends StatefulWidget {
  final SaleModel sale;

  const FakturView({super.key, required this.sale});

  @override
  State<FakturView> createState() => _FakturViewState();
}

class _FakturViewState extends State<FakturView> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isDownloading = false;
  GlobalSettingsModel? _settings;
  StreamSubscription<GlobalSettingsModel>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    final productService = Provider.of<ProductService>(context, listen: false);
    _settingsSubscription = productService.getGlobalSettings().listen((settings) {
      if (mounted) {
        setState(() {
          _settings = settings;
        });
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  // Generates formatted invoice text for sharing / clipboard
  String _generateInvoiceText() {
    final publisherName = _settings?.publisherName ?? 'Penerbit Jagaddhita';
    final publisherSlogan = _settings?.publisherSlogan ?? 'Edukasi Bangsa';

    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(widget.sale.createdAt);
    final statusStr = widget.sale.paymentStatus.toUpperCase();
    final itemsNames = widget.sale.productNames;
    final itemsPrices = widget.sale.productPrices;
    final itemsQuantities = widget.sale.productQuantities;

    final buffer = StringBuffer();
    buffer.writeln('------------------------------------------');
    buffer.writeln('          FAKTUR PENJUALAN BUKU           ');
    buffer.writeln('          ${publisherName.toUpperCase()}             ');
    buffer.writeln('------------------------------------------');
    buffer.writeln('ID Transaksi : ${widget.sale.id.toUpperCase()}');
    buffer.writeln('Tanggal      : $dateStr');
    buffer.writeln('Status       : $statusStr');
    buffer.writeln('Agen         : ${widget.sale.details['agent_name'] ?? 'Unknown'}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('PELANGGAN:');
    buffer.writeln('Nama         : ${widget.sale.customerName}');
    buffer.writeln('Nomor HP     : ${widget.sale.customerPhone}');
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

    final sisa = widget.sale.totalPrice - widget.sale.paidAmount;
    buffer.writeln('------------------------------------------');
    buffer.writeln('Total Bruto  : ${AppFormatters.currency(widget.sale.totalPrice)}');
    buffer.writeln(
      'Diskon/Komisi: ${AppFormatters.currency(widget.sale.commissionAmount)}',
    );
    buffer.writeln(
      'Total Netto  : ${AppFormatters.currency(widget.sale.totalPrice - widget.sale.commissionAmount)}',
    );
    buffer.writeln('Jumlah Bayar : ${AppFormatters.currency(widget.sale.paidAmount)}');
    buffer.writeln('Sisa Tagihan : ${AppFormatters.currency(sisa)}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('Terima kasih telah berbelanja!');
    buffer.writeln('$publisherName - $publisherSlogan');

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

  Future<void> _downloadInvoice() async {
    setState(() => _isDownloading = true);
    try {
      // 1. Generate PDF bytes using modular helper
      final pdfBytes = await generateFakturPdf(widget.sale, _settings);

      // 2. Save using FilePicker
      final fileName = 'Faktur_${widget.sale.id.toUpperCase()}.pdf';

      final path = await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: pdfBytes,
      );

      if (path != null) {
        if (!kIsWeb) {
          final file = File(path);
          await file.writeAsBytes(pdfBytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faktur berhasil diunduh sebagai PDF!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading invoice PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh faktur PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // White Invoice sheet wrapped in horizontal scroll view and RepaintBoundary to preserve PDF aspect ratio
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _globalKey,
                child: SizedBox(
                  width: 620, // Spacious fixed width matching printable invoice ratio to prevent squishing
                  child: FakturPrintableSheet(
                    sale: widget.sale,
                    settings: _settings,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action button row
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
                    onPressed: _isDownloading ? null : _downloadInvoice,
                    icon: _isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(
                      _isDownloading ? 'Mengunduh...' : 'Unduh PDF',
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
}
