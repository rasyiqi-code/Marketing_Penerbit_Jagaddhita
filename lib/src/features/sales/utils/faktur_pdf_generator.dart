import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Helper to render vector-based slanted blocks directly on PDF canvas
pw.Widget pdfSlantedContainer({
  required double width,
  required double height,
  required PdfColor color,
  required bool slantLeft,
  required bool slantRight,
  double slantWidth = 10.0,
  pw.Widget? child,
}) {
  return pw.Stack(
    alignment: pw.Alignment.center,
    children: [
      pw.CustomPaint(
        size: PdfPoint(width, height),
        painter: (PdfGraphics canvas, PdfPoint size) {
          final topLeftX = slantLeft ? slantWidth : 0.0;
          final topRightX = size.x;
          final bottomRightX = slantRight ? size.x - slantWidth : size.x;
          final bottomLeftX = slantLeft ? 0.0 : 0.0;

          canvas
            ..moveTo(topLeftX, size.y)
            ..lineTo(topRightX, size.y)
            ..lineTo(bottomRightX, 0)
            ..lineTo(bottomLeftX, 0)
            ..setFillColor(color)
            ..fillPath();
        },
      ),
      if (child != null)
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: slantLeft ? slantWidth : 0.0,
            right: slantRight ? slantWidth : 0.0,
          ),
          child: child,
        ),
    ],
  );
}

/// Standalone PDF invoice generator matching the red-and-charcoal diagonal layout
Future<Uint8List> generateFakturPdf(SaleModel sale, GlobalSettingsModel? settings) async {
  final pdf = pw.Document();

  final publisherName = settings?.publisherName ?? 'Penerbit Jagaddhita';
  final publisherSlogan = settings?.publisherSlogan ?? 'Edukasi Bangsa';

  final bankName = settings?.invoiceBankName ?? 'BCA';
  final bankAccountNo = settings?.invoiceBankAccountNo ?? '1234-5678-910';
  final bankAccountName = settings?.invoiceBankAccountName ?? publisherName;
  final contactPhone = settings?.invoiceContactPhone ?? '+62 822-8493-2038';
  final contactEmail = settings?.invoiceContactEmail ?? 'info@jagaddhita.id';
  final webUrl = settings?.webBaseUrl ?? 'www.jagaddhita.id';
  final displayWeb = webUrl
      .replaceAll('https://', '')
      .replaceAll('http://', '')
      .split('/')
      .first;

  // Load publisher logo bytes safely from assets
  pw.MemoryImage? logoImage;
  try {
    final logoBytes = (await rootBundle.load('assets/logo.png')).buffer.asUint8List();
    logoImage = pw.MemoryImage(logoBytes);
  } catch (e) {
    // Falls back gracefully if asset is missing
  }

  final dateStr = DateFormat(
    'dd MMMM yyyy, HH:mm',
    'id_ID',
  ).format(sale.createdAt);

  final isLunas = sale.paymentStatus.toUpperCase() == 'LUNAS';
  final isComplete = sale.paymentStatus.toUpperCase() == 'COMPLETE';
  final isDp = sale.paymentStatus.toUpperCase() == 'DP';
  final isPending = sale.paymentStatus.toUpperCase() == 'PENDING';

  PdfColor stampColor;
  String stampText;
  if (isComplete || isLunas) {
    stampColor = PdfColors.green;
    stampText = 'PAID / LUNAS';
  } else if (isDp) {
    stampColor = PdfColors.orange;
    stampText = 'DP / SEBAGIAN';
  } else if (isPending) {
    stampColor = PdfColors.grey;
    stampText = 'PENDING';
  } else {
    stampColor = PdfColors.red;
    stampText = sale.paymentStatus.toUpperCase();
  }

  final primaryRed = PdfColor.fromHex('#D32F2F');
  final darkCharcoal = PdfColor.fromHex('#212121');

  final itemsNames = sale.productNames;
  final itemsPrices = sale.productPrices;
  final itemsQuantities = sale.productQuantities;

  // Exact PDF page dimensions calculations (A4 width = 595.27, margins = 24 each side)
  const headerCol1 = 243.23;
  const headerCol2 = 121.61;
  const headerCol3 = 60.80;
  const headerCol4 = 121.61;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero, // Full-bleed margins for header & footer shapes
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Centered premium watermark
            pw.Positioned.fill(
              child: pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor(stampColor.red, stampColor.green, stampColor.blue, 0.12),
                        width: 4,
                      ),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    ),
                    child: pw.Text(
                      stampText,
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor(stampColor.red, stampColor.green, stampColor.blue, 0.12),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // 1. Premium diagonal brand-coloured header block
            pw.Stack(
              children: [
                pw.Container(width: 595.27, height: 110, color: PdfColors.white),
                pw.Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: pdfSlantedContainer(
                    width: 285,
                    height: 110,
                    color: PdfColor.fromHex('#2E7D32'), // Logo Green
                    slantLeft: true,
                    slantRight: false,
                    slantWidth: 28,
                  ),
                ),
                pw.Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: pdfSlantedContainer(
                    width: 275, // 10 points narrower
                    height: 110,
                    color: PdfColor.fromHex('#FBC02D'), // Logo Yellow
                    slantLeft: true,
                    slantRight: false,
                    slantWidth: 28,
                  ),
                ),
                // Brand Info (Centred horizontally on clean white left-background)
                pw.Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: pw.SizedBox(
                    width: 310, // Dedicated left area
                    child: pw.Center(
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min, // Hug content and center
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logoImage != null) ...[
                            pw.Image(
                              logoImage,
                              height: 50, // Larger height letting horizontal scale naturally without squishing
                              fit: pw.BoxFit.contain,
                            ),
                            pw.SizedBox(width: 12),
                          ],
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                publisherName.toUpperCase(),
                                style: pw.TextStyle(
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#212121'), // Crisp arang charcoal
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                publisherSlogan,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#2E7D32'), // Elegant brand green
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Invoice Metadata (Centred horizontally on yellow right-background)
                pw.Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: pw.SizedBox(
                    width: 275, // Dedicated right area
                    child: pw.Center(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center, // Center text horizontally inside block
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'FAKTUR / INVOICE',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#212121'), // Crisp arang charcoal
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Invoice No: #${sale.id.toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#212121'), // Crisp arang charcoal
                            ),
                          ),
                          pw.Text(
                            'Invoice Date: $dateStr',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#37474F'), // Elegant dark slate
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Content section with padded columns and table
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Metadata Row
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Client
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'INVOICE TO',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              sale.customerName,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Phone: ${sale.customerPhone}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.Text(
                              'Email: ${sale.details['customer_email'] ?? 'customer@email.com'}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Seller
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'INVOICE FROM',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              sale.details['agent_name'] ?? 'Marketing Partner',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Company: $publisherName',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.Text(
                              'Phone: ${sale.details['agent_phone'] ?? '+62 812-3456-7890'}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Table of items with slanted headers
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Column(
                      children: [
                        // Headers
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pdfSlantedContainer(
                              width: headerCol1,
                              height: 32,
                              color: darkCharcoal,
                              slantLeft: false,
                              slantRight: true,
                              slantWidth: 10,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                child: pw.Text(
                                  'ITEM DESCRIPTION',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                            ),
                            pdfSlantedContainer(
                              width: headerCol2,
                              height: 32,
                              color: primaryRed,
                              slantLeft: true,
                              slantRight: true,
                              slantWidth: 10,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                child: pw.Text(
                                  'PRICE',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ),
                            pdfSlantedContainer(
                              width: headerCol3,
                              height: 32,
                              color: primaryRed,
                              slantLeft: true,
                              slantRight: true,
                              slantWidth: 10,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                child: pw.Text(
                                  'QTY.',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                            pdfSlantedContainer(
                              width: headerCol4,
                              height: 32,
                              color: primaryRed,
                              slantLeft: true,
                              slantRight: false,
                              slantWidth: 10,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                child: pw.Text(
                                  'TOTAL',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Data rows
                        ...List.generate(itemsNames.length, (idx) {
                          final name = itemsNames[idx];
                          final price = itemsPrices.length > idx ? itemsPrices[idx] : 0.0;
                          final qty = itemsQuantities.length > idx ? itemsQuantities[idx] : 1;
                          final subtotal = price * qty;
                          final isEven = idx % 2 == 0;
                          final rowBgColor = isEven ? PdfColors.white : PdfColor.fromHex('#F9F9F9');

                          return pw.Container(
                            color: rowBgColor,
                            padding: const pw.EdgeInsets.symmetric(vertical: 8),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: headerCol1,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                  child: pw.Text(
                                    name,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey900,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: headerCol2,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                  child: pw.Text(
                                    AppFormatters.currency(price),
                                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Container(
                                  width: headerCol3,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                  child: pw.Text(
                                    '$qty',
                                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  width: headerCol4,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                  child: pw.Text(
                                    AppFormatters.currency(subtotal),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                      color: PdfColors.black,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Calculations and Payment Columns
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left info
                      pw.Expanded(
                        flex: 10,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'PAYMENT METHOD',
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.grey600,
                                        ),
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Text(
                                        'Bank Transfer / VA',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        '$bankName: $bankAccountNo',
                                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                                      ),
                                      pw.Text(
                                        'A/N: $bankAccountName',
                                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'CONTACT INFO',
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.grey600,
                                        ),
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Text(
                                        'WA: $contactPhone',
                                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Text(
                                        'Email: $contactEmail',
                                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                                      ),
                                      pw.Text(
                                        'Web: $displayWeb',
                                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 16),
                            pw.Text(
                              'THANK YOU FOR DOING BUSINESS WITH US.',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryRed,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'TERMS & CONDITIONS',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Harap lakukan pembayaran sesuai nominal sisa tagihan. Faktur ini merupakan bukti sah transaksi penjualan buku Penerbit Jagaddhita.',
                              style: const pw.TextStyle(
                                fontSize: 8.5,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 24),
                      // Right summary details
                      pw.Expanded(
                        flex: 9,
                        child: pw.Column(
                          children: [
                            _pdfSummaryRow('Total Harga', sale.totalPrice),
                            _pdfSummaryRow(
                              'Paid (Jumlah Dibayar)',
                              sale.paidAmount,
                            ),
                            pw.SizedBox(height: 8),
                            // Slanted outstanding block row
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pdfSlantedContainer(
                                  width: 107.76,
                                  height: 26,
                                  color: darkCharcoal,
                                  slantLeft: false,
                                  slantRight: true,
                                  slantWidth: 8,
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                    child: pw.Text(
                                      'Total Sisa:',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 9,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                pdfSlantedContainer(
                                  width: 140.10,
                                  height: 26,
                                  color: primaryRed,
                                  slantLeft: true,
                                  slantRight: false,
                                  slantWidth: 8,
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                                    child: pw.Text(
                                      AppFormatters.currency(sale.totalPrice - sale.paidAmount),
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 10,
                                        color: PdfColors.white,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 32),

                  // Signature Row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      // Signature line
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 120,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Authorized Sign',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // 3. Diagonal Bottom Accent Bar
            pw.Stack(
              children: [
                pw.Container(width: 595.27, height: 16, color: darkCharcoal),
                pdfSlantedContainer(
                  width: 370,
                  height: 16,
                  color: primaryRed,
                  slantLeft: false,
                  slantRight: true,
                  slantWidth: 16,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
),
  );

  return pdf.save();
}

pw.Widget _pdfSummaryRow(String label, double amount, {bool isDiscount = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          '${isDiscount ? "-" : ""}${AppFormatters.currency(amount)}',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
      ],
    ),
  );
}
