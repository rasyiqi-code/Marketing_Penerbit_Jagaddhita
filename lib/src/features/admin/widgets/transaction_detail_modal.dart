import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_timeline.dart';

import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/faktur_view.dart';

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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detail Transaksi',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: sale.paymentStatus == SaleModel.statusComplete
                      ? Colors.purple[50]
                      : (sale.paymentStatus == 'LUNAS'
                            ? Colors.green[50]
                            : Colors.orange[50]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sale.paymentStatus == SaleModel.statusComplete
                        ? Colors.purple
                        : (sale.paymentStatus == 'LUNAS'
                              ? Colors.green
                              : Colors.orange),
                  ),
                ),
                child: Text(
                  sale.paymentStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sale.paymentStatus == SaleModel.statusComplete
                        ? Colors.purple
                        : (sale.paymentStatus == 'LUNAS'
                              ? Colors.green
                              : Colors.orange),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Action: Lihat Faktur Button ───────────────────────
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FakturView(sale: sale)),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text(
                      'Lihat Faktur Penjualan',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  _buildDetailRow(
                    context,
                    'Tanggal',
                    dateFormat.format(sale.createdAt),
                  ),
                  _buildDetailRow(
                    context,
                    'Customer',
                    '${sale.customerName} (${sale.customerPhone})',
                  ),
                  const Divider(height: 12),
                  const Text('Daftar Buku', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
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
                  const Divider(height: 12),
                  if (sale.details['sekolah'] != null)
                    _buildDetailRow(
                      context,
                      'Sekolah Tujuan',
                      sale.details['sekolah'],
                    ),
                  if (sale.details['nama_pemesan'] != null)
                    _buildDetailRow(
                      context,
                      'Nama Pemesan',
                      sale.details['nama_pemesan'],
                    ),
                  if (sale.details['alamat_pengiriman'] != null)
                    _buildDetailRow(
                      context,
                      'Alamat Kirim',
                      sale.details['alamat_pengiriman'],
                    ),
                  if (sale.details['telepon_penerima'] != null)
                    _buildDetailRow(
                      context,
                      'Telp Penerima',
                      sale.details['telepon_penerima'],
                    ),
                  if (sale.details['judul_naskah'] != null)
                    _buildDetailRow(
                      context,
                      'Naskah',
                      sale.details['judul_naskah'],
                    ),
                  _buildDetailRow(
                    context,
                    'Nama Agent',
                    sale.details['agent_name'] ??
                        sale.details['buyer_name'] ??
                        '-',
                  ),
                  if (sale.details['marketing_category'] != null && sale.details['marketing_category'] != 'none')
                    _buildDetailRow(
                      context,
                      'Kategori Marketing',
                      sale.details['marketing_category'].toString().toUpperCase(),
                    ),
                  if (sale.details['judul_layout'] != null)
                    _buildDetailRow(
                      context,
                      'Judul Layout',
                      sale.details['judul_layout'],
                    ),
                  if (sale.details['nama_penulis'] != null)
                    _buildDetailRow(
                      context,
                      'Penulis',
                      sale.details['nama_penulis'],
                    ),
                  if (sale.details['nama_mitra'] != null)
                    _buildDetailRow(
                      context,
                      'Mitra',
                      sale.details['nama_mitra'],
                    ),
                  _buildDetailRow(
                    context,
                    'No. Telepon',
                    sale.details['buyer_phone'] ?? '-',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (sale.paidAmount > 0 &&
                                    sale.paidAmount < sale.totalPrice)
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  (sale.paidAmount > 0 &&
                                      sale.paidAmount < sale.totalPrice)
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ),
                          child: Text(
                            (sale.paidAmount > 0 &&
                                    sale.paidAmount < sale.totalPrice)
                                ? 'DP (Cicilan)'
                                : 'LUNAS (Full Payment)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color:
                                  (sale.paidAmount > 0 &&
                                      sale.paidAmount < sale.totalPrice)
                                  ? Colors.blue[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sale.transactionProofUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
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
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
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
                      },
                      child: NetworkImageWeb(
                        imageUrl: sale.transactionProofUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Rincian Keuangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Total Harga',
                    currencyFormat.format(sale.totalPrice),
                  ),
                  _buildDetailRow(
                    context,
                    (sale.paidAmount > 0 && sale.paidAmount < sale.totalPrice)
                        ? 'Sudah Dibayar (DP)'
                        : 'Jumlah Dibayar',
                    currencyFormat.format(sale.paidAmount),
                  ),
                  if (sale.paidAmount < sale.totalPrice)
                    _buildDetailRow(
                      context,
                      'Sisa Tagihan',
                      currencyFormat.format(sale.totalPrice - sale.paidAmount),
                    ),
                  _buildDetailRow(
                    context,
                    (sale.paymentStatus == SaleModel.statusComplete)
                        ? 'Komisi (Masuk Saldo)'
                        : 'Potensi Komisi',
                    currencyFormat.format(sale.commissionAmount),
                  ),
                  _buildDetailRow(
                    context,
                    (sale.paymentStatus == SaleModel.statusComplete)
                        ? 'Bonus Pulsa (Masuk Saldo)'
                        : 'Potensi Bonus Pulsa',
                    currencyFormat.format(sale.pulsaBonusAmount),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agen Lokal (Mitra)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow(context, 'Agent ID', sale.userId),
                  const SizedBox(height: 10),
                  TransactionTimeline(history: sale.history),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tutup', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
