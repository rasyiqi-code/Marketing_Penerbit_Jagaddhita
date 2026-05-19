import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_timeline.dart';

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

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
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
                  const SizedBox(height: 32),

                  // ── Identitas transaksi ───────────────────────────────
                  _DetailRow('ID Transaksi',
                      sale.id.substring(0, 8).toUpperCase()),
                  _DetailRow('Tanggal',
                      AppFormatters.dateTime(sale.createdAt)),
                  _DetailRow('Status', sale.paymentStatus),
                  _DetailRow('Total Transaksi',
                      AppFormatters.currency(sale.totalPrice)),
                  const Divider(height: 32),

                  // ── Item ─────────────────────────────────────────────
                  const Text('Rincian Item',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _DetailRow('Produk',
                      sale.details['product_name'] ?? '-'),
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
                  if (sale.details['nama_pemesan'] != null)
                    _DetailRow(
                        'Nama Pemesan', sale.details['nama_pemesan']),
                  if (sale.details['alamat_pengiriman'] != null)
                    _DetailRow(
                        'Alamat Kirim', sale.details['alamat_pengiriman']),
                  if (sale.details['telepon_penerima'] != null)
                    _DetailRow('Telp', sale.details['telepon_penerima']),

                  const Divider(height: 32),

                  // ── Bukti ─────────────────────────────────────────────
                  if (sale.transactionProofUrl != null) ...[
                    const Text('Bukti Transaksi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                    const Divider(height: 32),
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
                  const Divider(height: 32),

                  // ── Pendapatan ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                          color: Colors.green,
                        ),
                        if (sale.pulsaBonusAmount > 0)
                          _SummaryRow(
                            'Bonus Tambahan',
                            sale.pulsaBonusAmount,
                            isComplete: isComplete,
                            color: Colors.blue,
                          ),
                        if ((sale.totalMarkup ?? 0) > 0)
                          _SummaryRow(
                            'Keuntungan Markup',
                            (sale.totalMarkup ?? 0).toDouble(),
                            isComplete: isComplete,
                            color: Colors.purple,
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
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

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
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
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
              color: isComplete ? color : Colors.orange[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
