import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Card ringkasan transaksi penjualan di halaman riwayat.
class SaleCard extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onTap;
  final VoidCallback onPelunasan;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onTap,
    required this.onPelunasan,
  });

  @override
  Widget build(BuildContext context) {
    final isLunas = sale.paymentStatus.toUpperCase() == 'LUNAS';
    final isComplete = sale.paymentStatus.toUpperCase() == 'COMPLETE';
    const houseName = 'Penerbitan Buku';

    final productName = sale.details['product_name'] ??
        sale.details['book_title'] ??
        'Product #${sale.productId.substring(0, 4)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(
                    isLunas: isLunas,
                    label: isLunas ? 'PAID' : sale.paymentStatus,
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Product name + category ───────────────────────────────
              Text(
                productName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                houseName,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),

              // ── Price summary ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Harga',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    AppFormatters.currency(sale.totalPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Commission / Bonus ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Masuk Saldo' : 'Estimasi Potensi',
                        style: TextStyle(
                          fontSize: 12,
                          color: isComplete
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.orange[800],
                        ),
                      ),
                      Text(
                        'Komisi: ${AppFormatters.currency(sale.commissionAmount)}',
                        style: GoogleFonts.outfit(
                          color: isComplete
                              ? Colors.green[700]
                              : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (sale.pulsaBonusAmount > 0)
                        Text(
                          'Bonus: ${AppFormatters.currency(sale.pulsaBonusAmount)}',
                          style: GoogleFonts.outfit(
                            color: isComplete
                                ? Colors.blue[700]
                                : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  Icon(Icons.chevron_right,
                      color: Theme.of(context).dividerColor),
                ],
              ),

              // ── Markup ────────────────────────────────────────────────
              if ((sale.totalMarkup ?? 0) > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Keuntungan Markup',
                        style:
                            TextStyle(fontSize: 12, color: Colors.green[700])),
                    Text(
                      AppFormatters.currency(sale.totalMarkup ?? 0),
                      style: GoogleFonts.outfit(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],

              // ── DP info + pelunasan button ────────────────────────────
              if (sale.paymentStatus == 'DP' && sale.paidAmount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'DP Terbayar: ${AppFormatters.currency(sale.paidAmount)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPelunasan,
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Lunasi Sekarang & Upload Bukti'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLunas;
  final String label;
  const _StatusBadge({required this.isLunas, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isLunas ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isLunas ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }
}
