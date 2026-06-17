import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'shared/sale_status_badge.dart';
import 'shared/sale_shipping_badge.dart';
import 'shared/sale_payment_info_row.dart';

/// Card ringkasan transaksi penjualan di halaman riwayat (didesain ulang menjadi Flat List Item).
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
    const houseName = 'Penjualan Buku';

    final productName = sale.details['product_name'] ??
        sale.details['book_title'] ??
        'Product #${sale.productId.substring(0, 4)}';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: Status & Tanggal ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SaleStatusBadge(
                        status: sale.paymentStatus,
                        label: isComplete ? 'COMPLETE' : (isLunas ? 'PAID' : sale.paymentStatus.toUpperCase()),
                      ),
                      if (sale.shippingStatus != null) ...[
                        const SizedBox(width: 6),
                        SaleShippingBadge(
                          status: sale.shippingStatus!,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Product name & Customer ──────────────────────────────
              Text(
                productName,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Customer: ${sale.customerName}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                houseName,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),

              // ── Financial info row ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Masuk Saldo' : 'Estimasi Potensi',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: isComplete
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Komisi: ${AppFormatters.currency(sale.commissionAmount)}',
                        style: GoogleFonts.outfit(
                          color: isComplete
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (sale.pulsaBonusAmount > 0)
                        Text(
                          'Bonus: ${AppFormatters.currency(sale.pulsaBonusAmount)}',
                          style: GoogleFonts.outfit(
                            color: isComplete
                               ? AppTheme.primaryColor
                                : AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Harga',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        AppFormatters.currency(sale.totalPrice),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Keuntungan Markup ───────────────────────────────────
              if ((sale.totalMarkup ?? 0) > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keuntungan Markup',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.primaryColor),
                    ),
                    Text(
                      AppFormatters.currency(sale.totalMarkup ?? 0),
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],

              // ── DP & COD info + pelunasan button ──────────────────────
              SalePaymentInfoRow(
                sale: sale,
                onPelunasan: onPelunasan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
