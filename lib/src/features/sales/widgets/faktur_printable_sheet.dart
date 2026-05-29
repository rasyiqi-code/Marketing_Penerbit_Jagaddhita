import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'slanted_clipper.dart';

class FakturPrintableSheet extends StatelessWidget {
  final SaleModel sale;
  final GlobalSettingsModel? settings;

  const FakturPrintableSheet({
    super.key,
    required this.sale,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
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

    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(sale.createdAt);

    final isLunas = sale.paymentStatus.toUpperCase() == 'LUNAS';
    final isComplete = sale.paymentStatus.toUpperCase() == 'COMPLETE';
    final isDp = sale.paymentStatus.toUpperCase() == 'DP';
    final isPending = sale.paymentStatus.toUpperCase() == 'PENDING';
    final isCod = sale.paymentStatus.toUpperCase() == 'COD';

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
    } else if (isCod) {
      stampColor = Colors.blue;
      stampText = 'COD / BAYAR DI TEMPAT';
    } else {
      stampColor = Colors.red;
      stampText = sale.paymentStatus.toUpperCase();
    }

    final itemsNames = sale.productNames;
    final itemsPrices = sale.productPrices;
    final itemsQuantities = sale.productQuantities;

    final headerTextStyle = GoogleFonts.outfit(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Colors.white,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Premium Diagonal Brand-Coloured Header Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                // Clean white background for the logo and brand
                Container(
                  height: 100,
                  color: Colors.white,
                ),
                // Green slanted accent strip on the right
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 285,
                  child: const SlantedContainer(
                    color: Color(0xFF2E7D32), // Logo Green
                    slantLeft: true,
                    slantRight: false,
                    slantWidth: 28,
                    child: SizedBox.expand(),
                  ),
                ),
                // Yellow slanted block on the right (10px narrower to show the green edge)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 275,
                  child: const SlantedContainer(
                    color: Color(0xFFFBC02D), // Logo Yellow
                    slantLeft: true,
                    slantRight: false,
                    slantWidth: 28,
                    child: SizedBox.expand(),
                  ),
                ),
                // Brand Info (Centred horizontally on clean white left-background)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 320, // Dedicated left area
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Hug content and center
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 55, // Larger height letting horizontal scale naturally without squishing
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              publisherName.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF212121), // Crisp arang charcoal
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              publisherSlogan,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32), // Elegant brand green
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Invoice Metadata (Centred horizontally on yellow right-background)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 275, // Dedicated right area
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally inside block
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FAKTUR / INVOICE',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF212121), // High-contrast arang charcoal
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invoice No: #${sale.id.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF212121), // High-contrast arang charcoal
                          ),
                        ),
                        Text(
                          'Invoice Date: $dateStr',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF37474F), // Elegant dark slate
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Body Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Billing Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INVOICE TO (Customer)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVOICE TO',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            sale.customerName,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${sale.customerPhone}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Email: ${sale.details['customer_email'] ?? 'customer@email.com'}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // INVOICE FROM (Agent/Seller)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVOICE FROM',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            sale.details['agent_name'] ?? 'Marketing Partner',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Company: $publisherName',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Phone: ${sale.details['agent_phone'] ?? '+62 812-3456-7890'}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Slanted headers table
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Slanted Headers Block
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: SlantedContainer(
                              color: const Color(0xFF212121),
                              slantLeft: false,
                              slantRight: true,
                              slantWidth: 10,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Text('ITEM DESCRIPTION', style: headerTextStyle),
                              ),
                            ),
                          ),
                          const SizedBox(width: 1.5),
                          Expanded(
                            flex: 2,
                            child: SlantedContainer(
                              color: const Color(0xFFD32F2F),
                              slantLeft: true,
                              slantRight: true,
                              slantWidth: 10,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Text('PRICE', style: headerTextStyle, textAlign: TextAlign.right),
                              ),
                            ),
                          ),
                          const SizedBox(width: 1.5),
                          Expanded(
                            flex: 1,
                            child: SlantedContainer(
                              color: const Color(0xFFD32F2F),
                              slantLeft: true,
                              slantRight: true,
                              slantWidth: 10,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Text('QTY.', style: headerTextStyle, textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          const SizedBox(width: 1.5),
                          Expanded(
                            flex: 2,
                            child: SlantedContainer(
                              color: const Color(0xFFD32F2F),
                              slantLeft: true,
                              slantRight: false,
                              slantWidth: 10,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Text('TOTAL', style: headerTextStyle, textAlign: TextAlign.right),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Table Item Rows
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemsNames.length,
                        itemBuilder: (ctx, idx) {
                          final name = itemsNames[idx];
                          final price = itemsPrices.length > idx ? itemsPrices[idx] : 0.0;
                          final qty = itemsQuantities.length > idx ? itemsQuantities[idx] : 1;
                          final subtotal = price * qty;
                          final isEven = idx % 2 == 0;

                          return Container(
                            color: isEven ? Colors.white : const Color(0xFFF9F9F9),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.currency(price),
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '$qty',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.currency(subtotal),
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Calculations & Payment Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Payment, Contact, Slogan, and Terms
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Payment Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PAYMENT METHOD',
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                                                  if (isCod) ...[
                                      Text(
                                        'Cash on Delivery (COD)',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Bayar saat barang diterima',
                                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.black54),
                                      ),
                                    ] else ...[
                                      Text(
                                        'Bank Transfer / VA',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '$bankName: $bankAccountNo',
                                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.black54),
                                      ),
                                      Text(
                                        'A/N: $bankAccountName',
                                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.black54),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Contact Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONTACT INFO',
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'WA: $contactPhone',
                                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.black87),
                                    ),
                                    Text(
                                      'Email: $contactEmail',
                                      style: GoogleFonts.outfit(fontSize: 9, color: Colors.black54),
                                    ),
                                    Text(
                                      'Web: $displayWeb',
                                      style: GoogleFonts.outfit(fontSize: 9, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'THANK YOU FOR DOING BUSINESS WITH US.',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TERMS & CONDITIONS',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Harap lakukan pembayaran sesuai nominal sisa tagihan. Faktur ini merupakan bukti sah transaksi penjualan buku Penerbit Jagaddhita.',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right: Calculations + Diagonal Total Block
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          _summaryRow('Total Harga', sale.totalPrice),
                          _summaryRow(
                            'Paid (Jumlah Dibayar)',
                            sale.paidAmount,
                          ),
                          const SizedBox(height: 8),
                          // Diagonal Total Outstanding Block
                          Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: SlantedContainer(
                                  color: const Color(0xFF212121),
                                  slantLeft: false,
                                  slantRight: true,
                                  slantWidth: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Text(
                                      'Total Sisa:',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 13,
                                child: SlantedContainer(
                                  color: const Color(0xFFD32F2F),
                                  slantLeft: true,
                                  slantRight: false,
                                  slantWidth: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Text(
                                      AppFormatters.currency(sale.totalPrice - sale.paidAmount),
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
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
                const SizedBox(height: 36),

                // Signatures
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Signature + Stamp Image with local watermark overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/signature_stamp.png',
                              width: 150,
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Authorized Sign',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Watermark stamp on top of signature image
                        IgnorePointer(
                          child: Transform.rotate(
                            angle: -0.25,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: stampColor.withValues(alpha: 0.45),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                stampText,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: stampColor.withValues(alpha: 0.45),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Diagonal Bottom Accent Bar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Stack(
              children: [
                // Background dark arang
                Container(
                  height: 14,
                  color: const Color(0xFF212121),
                ),
                // Slanted red block covering left 60%
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.62,
                  child: SlantedContainer(
                    color: const Color(0xFFD32F2F),
                    slantLeft: false,
                    slantRight: true,
                    slantWidth: 16,
                    child: const SizedBox(height: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);
  }

  Widget _summaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}${AppFormatters.currency(amount)}',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
