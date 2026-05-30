import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_timeline.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/faktur_view.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';

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
    final isComplete = sale.paymentStatus == 'COMPLETE';
    final sisaTagihan = sale.totalPrice - sale.paidAmount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Detail Transaksi',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Action: Lihat Faktur Button ───────────────────────
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
                      elevation: 2,
                    ),
                  ),
                  if (sale.shippingStatus == 'DIKIRIM') ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Konfirmasi Barang Sampai'),
                            content: const Text('Apakah Anda yakin barang pesanan ini sudah sampai ke tangan pembeli?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Yakin'),
                              ),
                            ],
                          ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barang berhasil dikonfirmasi sampai!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context); // Close sheet to refresh
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal konfirmasi: $e')),
                            );
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
                        elevation: 2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Identitas transaksi ───────────────────────────────
                  _DetailRow('ID Transaksi',
                      sale.id.substring(0, 8).toUpperCase()),
                  _DetailRow('Tanggal',
                      AppFormatters.dateTime(sale.createdAt)),
                  _DetailRow('Status', sale.paymentStatus),
                  _DetailRow('Total Transaksi',
                      AppFormatters.currency(sale.totalPrice)),
                  _DetailRow('Jumlah Bayar',
                      AppFormatters.currency(sale.paidAmount)),
                  _DetailRow('Sisa Tagihan',
                      AppFormatters.currency(sisaTagihan)),
                  if (sale.shippingStatus != null) ...[
                    _DetailRow('Status Pengiriman', sale.shippingStatus!),
                    if (sale.shippingCourier != null)
                      _DetailRow('Ekspedisi', sale.shippingCourier!),
                    if (sale.shippingResi != null)
                      _DetailRow('No. Resi', sale.shippingResi!),
                  ],
                  
                  const Divider(height: 24),

                  // ── Customer Details ──────────────────────────────────
                  const Text('Info Pelanggan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _DetailRow('Nama Customer', sale.customerName),
                  _DetailRow('No. HP Customer', sale.customerPhone),

                  const Divider(height: 24),

                  // ── Item ─────────────────────────────────────────────
                  const Text('Rincian Item',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                        return _DetailRow(
                          '$name (x$qty)',
                          AppFormatters.currency(price * qty),
                        );
                      },
                    )
                  else
                    _DetailRow('Produk', sale.details['product_name'] ?? '-'),

                  if (sale.details['marketing_category'] != null &&
                      sale.details['marketing_category'] != 'none')
                    _DetailRow(
                      'Kategori Marketing',
                      sale.details['marketing_category']
                          .toString()
                          .toUpperCase(),
                    ),
                  // Legacy fields (backward-compat for old orders)
                  if (sale.details['sekolah'] != null)
                    _DetailRow('Sekolah Tujuan', sale.details['sekolah']),

                  const Divider(height: 24),

                  // ── Bukti ─────────────────────────────────────────────
                  if (sale.transactionProofUrl != null) ...[
                    const Text('Bukti Transaksi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetworkImageWeb(
                        imageUrl: sale.transactionProofUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          height: 200,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child:
                              const Center(child: Text('Gagal memuat gambar')),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                  ],

                  // ── Agen ─────────────────────────────────────────────
                  const Text('Info Agen',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _DetailRow(
                    'Nama Agen',
                    sale.details['agent_name'] ??
                        sale.details['buyer_name'] ??
                        '-',
                  ),
                  const Divider(height: 24),

                  // ── Pendapatan ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isComplete ? 'Masuk Saldo' : 'Potensi Pendapatan',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          'Komisi Penjualan',
                          sale.commissionAmount,
                          isComplete: isComplete,
                          color: AppTheme.primaryColor,
                        ),
                        if (sale.pulsaBonusAmount > 0)
                          _SummaryRow(
                            'Bonus Tambahan',
                            sale.pulsaBonusAmount,
                            isComplete: isComplete,
                            color: AppTheme.secondaryColor,
                          ),
                        if ((sale.totalMarkup ?? 0) > 0)
                          _SummaryRow(
                            'Keuntungan Markup',
                            (sale.totalMarkup ?? 0).toDouble(),
                            isComplete: isComplete,
                            color: AppTheme.primaryColor,
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              AppFormatters.currency(
                                sale.commissionAmount +
                                    sale.bonusAmount +
                                    sale.pulsaBonusAmount +
                                    (sale.totalMarkup ?? 0),
                              ),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isComplete
                                    ? AppTheme.primaryColor
                                    : AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Timeline ──────────────────────────────────────────
                  TransactionTimeline(history: sale.history),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Local helpers ──────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isComplete;
  final Color color;

  const _SummaryRow(
    this.label,
    this.amount, {
    required this.isComplete,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14)),
          Text(
            AppFormatters.currency(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isComplete ? color : AppTheme.accentColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
