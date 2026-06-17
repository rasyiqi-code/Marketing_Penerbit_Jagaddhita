import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Bagian tampilan rincian pendapatan dari suatu transaksi penjualan.
class SaleIncomeSection extends StatelessWidget {
  final SaleModel sale;

  const SaleIncomeSection({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final isComplete = sale.paymentStatus == 'COMPLETE';

    return Container(
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Komisi Penjualan',
            amount: sale.commissionAmount,
            isComplete: isComplete,
            color: AppTheme.primaryColor,
          ),
          if (sale.pulsaBonusAmount > 0)
            _SummaryRow(
              label: 'Bonus Tambahan',
              amount: sale.pulsaBonusAmount,
              isComplete: isComplete,
              color: AppTheme.secondaryColor,
            ),
          if ((sale.totalMarkup ?? 0) > 0)
            _SummaryRow(
              label: 'Keuntungan Markup',
              amount: (sale.totalMarkup ?? 0).toDouble(),
              isComplete: isComplete,
              color: AppTheme.primaryColor,
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                  color: isComplete ? AppTheme.primaryColor : AppTheme.accentColor,
                ),
              ),
            ],
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

  const _SummaryRow({
    required this.label,
    required this.amount,
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
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
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
