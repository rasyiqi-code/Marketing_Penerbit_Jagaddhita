import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_timeline.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/faktur_view.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/detail/sale_income_section.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';

enum SaleDetailMode { general, sales, admin }

class SaleDetailView extends StatelessWidget {
  final SaleModel sale;
  final SaleDetailMode mode;

  const SaleDetailView({
    super.key,
    required this.sale,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final sisaTagihan = sale.totalPrice - sale.paidAmount;
    final isLunas = sale.paymentStatus == 'LUNAS' || sale.paymentStatus == SaleModel.statusComplete;

    return Container(
      height: MediaQuery.of(context).size.height * (mode == SaleDetailMode.general ? 0.85 : 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detail Transaksi',
                  style: GoogleFonts.outfit(
                    fontSize: mode == SaleDetailMode.admin ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          const Divider(height: 24),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons for admin and sales mode
                  if (mode != SaleDetailMode.general) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FakturView(sale: sale)),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 20),
                      label: Text(
                        'Lihat Faktur Penjualan',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                    ),
                    if (mode == SaleDetailMode.sales && sale.shippingStatus == 'DIKIRIM') ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await AppDialogs.showConfirmDialog(
                            context: context,
                            title: 'Konfirmasi Barang Sampai',
                            content: 'Apakah Anda yakin barang pesanan ini sudah sampai ke tangan pembeli?',
                            confirmLabel: 'Yakin',
                            cancelLabel: 'Batal',
                          );
                          if (confirm == true) {
                            if (!context.mounted) return;
                            try {
                              final salesService = Provider.of<SalesService>(context, listen: false);
                              await salesService.updateShippingStatus(
                                sale.id,
                                'SAMPAI',
                                note: 'Barang telah diterima oleh customer (dikonfirmasi oleh marketing)',
                                actor: 'Marketing',
                              );
                              if (!context.mounted) return;
                              AppDialogs.showSuccessSnackBar(context, 'Barang berhasil dikonfirmasi sampai!');
                              Navigator.pop(context); // Close sheet to refresh
                            } catch (e) {
                              if (!context.mounted) return;
                              AppDialogs.showErrorSnackBar(context, 'Gagal konfirmasi: $e');
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                        label: Text(
                          'Konfirmasi Barang Sampai',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  // Core fields
                  _buildDetailRow(context, 'ID Transaksi', sale.id.substring(0, 8).toUpperCase()),
                  _buildDetailRow(context, 'Tanggal', dateFormat.format(sale.createdAt)),

                  // Mode-specific layouts
                  if (mode == SaleDetailMode.admin) ...[
                    _buildDetailRow(context, 'Customer', '${sale.customerName} (${sale.customerPhone})'),
                  ] else if (mode == SaleDetailMode.sales) ...[
                    _buildDetailRow(context, 'Status', sale.paymentStatus),
                    _buildDetailRow(context, 'Total Transaksi', AppFormatters.currency(sale.totalPrice)),
                    _buildDetailRow(context, 'Jumlah Bayar', AppFormatters.currency(sale.paidAmount)),
                    _buildDetailRow(context, 'Sisa Tagihan', AppFormatters.currency(sisaTagihan)),
                  ],

                  // Shipping info
                  if (sale.shippingStatus != null) ...[
                    _buildDetailRow(context, 'Status Pengiriman', sale.shippingStatus!),
                    if (sale.shippingCourier != null)
                      _buildDetailRow(context, 'Ekspedisi', sale.shippingCourier!),
                    if (sale.shippingResi != null)
                      _buildDetailRow(context, 'No. Resi', sale.shippingResi!),
                  ],

                  // Customer info section for sales
                  if (mode == SaleDetailMode.sales) ...[
                    const Divider(height: 24),
                    const Text('Info Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildDetailRow(context, 'Nama Customer', sale.customerName),
                    _buildDetailRow(context, 'No. HP Customer', sale.customerPhone),
                  ],

                  const Divider(height: 24),

                  // Item list
                  const Text('Daftar Buku', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (sale.productNames.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.productNames.length,
                      itemBuilder: (context, idx) {
                        final name = sale.productNames[idx];
                        final price = sale.productPrices.length > idx ? sale.productPrices[idx] : 0.0;
                        final qty = sale.productQuantities.length > idx ? sale.productQuantities[idx] : 1;
                        return _buildDetailRow(
                          context,
                          '$name (x$qty)',
                          currencyFormat.format(price * qty),
                        );
                      },
                    )
                  else
                    _buildDetailRow(
                      context,
                      'Produk',
                      sale.details['product_name'] ?? 'Unknown Product',
                    ),

                  // Additional Details (Admin & General fields)
                  if (sale.details['judul_naskah'] != null)
                    _buildDetailRow(context, 'Naskah', sale.details['judul_naskah']),

                  if (mode == SaleDetailMode.admin) ...[
                    if (sale.details['sekolah'] != null)
                      _buildDetailRow(context, 'Sekolah Tujuan', sale.details['sekolah']),
                    if (sale.details['nama_pemesan'] != null)
                      _buildDetailRow(context, 'Nama Pemesan', sale.details['nama_pemesan']),
                    if (sale.details['alamat_pengiriman'] != null)
                      _buildDetailRow(context, 'Alamat Kirim', sale.details['alamat_pengiriman']),
                    if (sale.details['telepon_penerima'] != null)
                      _buildDetailRow(context, 'Telp Penerima', sale.details['telepon_penerima']),
                    if (sale.details['judul_layout'] != null)
                      _buildDetailRow(context, 'Judul Layout', sale.details['judul_layout']),
                    if (sale.details['nama_penulis'] != null)
                      _buildDetailRow(context, 'Penulis', sale.details['nama_penulis']),
                    if (sale.details['nama_mitra'] != null)
                      _buildDetailRow(context, 'Mitra', sale.details['nama_mitra']),
                  ] else if (mode == SaleDetailMode.sales) ...[
                    if (sale.details['sekolah'] != null)
                      _buildDetailRow(context, 'Sekolah Tujuan', sale.details['sekolah']),
                  ],

                  _buildDetailRow(
                    context,
                    'Nama Agent',
                    sale.details['agent_name'] ?? sale.details['buyer_name'] ?? '-',
                  ),

                  if (sale.details['marketing_category'] != null &&
                      sale.details['marketing_category'] != 'none')
                    _buildDetailRow(
                      context,
                      'Kategori Marketing',
                      sale.details['marketing_category'].toString().toUpperCase(),
                    ),

                  if (mode == SaleDetailMode.general)
                    _buildDetailRow(context, 'No. Telepon', sale.details['buyer_phone'] ?? '-'),

                  // Payment method for admin
                  if (mode == SaleDetailMode.admin)
                    _buildPaymentMethodRow(context),

                  // Proof of transaction
                  if (sale.transactionProofUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showZoomableImage(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImageWeb(
                          imageUrl: sale.transactionProofUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 24),

                  // Income & Finance sections
                  if (mode == SaleDetailMode.sales) ...[
                    SaleIncomeSection(sale: sale),
                    const SizedBox(height: 24),
                  ] else ...[
                    const Text(
                      'Rincian Keuangan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Total Harga', currencyFormat.format(sale.totalPrice)),
                    _buildDetailRow(
                      context,
                      (mode == SaleDetailMode.admin && sale.paidAmount > 0 && sale.paidAmount < sale.totalPrice)
                          ? 'Sudah Dibayar (DP)'
                          : 'Jumlah Dibayar',
                      currencyFormat.format(sale.paidAmount),
                    ),
                    if (sale.paidAmount < sale.totalPrice)
                      _buildDetailRow(context, 'Sisa Tagihan', currencyFormat.format(sisaTagihan)),
                    _buildDetailRow(
                      context,
                      isLunas ? 'Komisi (Masuk Saldo)' : 'Potensi Komisi',
                      currencyFormat.format(sale.commissionAmount),
                    ),
                    _buildDetailRow(
                      context,
                      isLunas ? 'Bonus Pulsa (Masuk Saldo)' : 'Potensi Bonus Pulsa',
                      currencyFormat.format(sale.pulsaBonusAmount),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Agen Lokal (Mitra)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Agent ID', sale.userId),
                  ],

                  const SizedBox(height: 16),
                  TransactionTimeline(history: sale.history),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Close button for general/dialog style
          if (mode == SaleDetailMode.general || mode == SaleDetailMode.admin) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    Color textColor;

    if (sale.paymentStatus == SaleModel.statusComplete || sale.paymentStatus == 'LUNAS') {
      badgeColor = mode == SaleDetailMode.admin ? Colors.green[50]! : AppTheme.primaryColor.withValues(alpha: 0.1);
      textColor = mode == SaleDetailMode.admin ? Colors.green : AppTheme.primaryColor;
    } else {
      badgeColor = mode == SaleDetailMode.admin ? Colors.orange[50]! : AppTheme.accentColor.withValues(alpha: 0.15);
      textColor = mode == SaleDetailMode.admin ? Colors.orange : AppTheme.accentColor;
    }

    if (sale.paymentStatus == SaleModel.statusComplete && mode == SaleDetailMode.admin) {
      badgeColor = Colors.purple[50]!;
      textColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor),
      ),
      child: Text(
        sale.paymentStatus,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: mode == SaleDetailMode.admin ? 11 : 13,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(BuildContext context) {
    final isCod = sale.details['requested_status'] == 'COD' || sale.paymentStatus == SaleModel.statusCod;
    final isDp = sale.details['requested_status'] == 'DP' || (sale.paidAmount > 0 && sale.paidAmount < sale.totalPrice);

    Color color = isCod ? Colors.orange : (isDp ? Colors.blue : Colors.green);
    String label = isCod ? 'COD (Bayar di Tempat)' : (isDp ? 'DP (Cicilan)' : 'LUNAS (Full Payment)');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Metode Pembayaran',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isCod ? Colors.orange[800] : (isDp ? Colors.blue[800] : Colors.green[800]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: mode == SaleDetailMode.admin ? 12 : 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: mode == SaleDetailMode.admin ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomableImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.loose,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: NetworkImageWeb(
                  imageUrl: sale.transactionProofUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
