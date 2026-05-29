import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Displays the auto-calculated price breakdown for a sale order.
class SalesCalculationCard extends StatelessWidget {
  final Color color;
  final String marketingCategory;
  final double bruto;
  final double discountPercent;
  final double discountAmount;
  final double netto;
  final double commissionAmount;
  final double pulsaBonusAmount;

  const SalesCalculationCard({
    super.key,
    required this.color,
    required this.marketingCategory,
    required this.bruto,
    required this.discountPercent,
    required this.discountAmount,
    required this.netto,
    required this.commissionAmount,
    required this.pulsaBonusAmount,
  });

  String get _categoryLabel {
    if (marketingCategory == 'gold') return 'Reseller Gold';
    if (marketingCategory == 'platinum') return 'Reseller Platinum';
    if (marketingCategory == 'premium') return 'Reseller Premium';
    return 'Marketing';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.calculate_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Kalkulasi Otomatis',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, color: color),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _categoryLabel,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calculation rows
          _CalcRow(
            label: 'Total Bruto',
            value: AppFormatters.currency(bruto),
            isBold: false,
          ),
          const SizedBox(height: 8),
          _CalcRow(
            label: 'Diskon ${discountPercent.toStringAsFixed(0)}%',
            value: '- ${AppFormatters.currency(discountAmount)}',
            valueColor: AppTheme.secondaryColor,
          ),
          const Divider(height: 24),
          _CalcRow(
            label: 'Total Netto (Dibayar Marketing)',
            value: AppFormatters.currency(netto),
            isBold: true,
            valueColor: color,
          ),
          if (commissionAmount > 0) ...[
            const SizedBox(height: 8),
            _CalcRow(
              label: 'Pendapatan Marketing',
              value: AppFormatters.currency(commissionAmount),
              valueColor: AppTheme.primaryColor,
              isBold: true,
            ),
          ],
          if (pulsaBonusAmount > 0) ...[
            const Divider(height: 16),
            _CalcRow(
              label: '🎁 Bonus Pulsa',
              value: AppFormatters.currency(pulsaBonusAmount),
              valueColor: AppTheme.accentColor,
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _CalcRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color:
                valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Banner showing agent name and marketing category.
class SalesAgentBanner extends StatelessWidget {
  final String agentName;
  final String? category;

  const SalesAgentBanner({
    super.key,
    required this.agentName,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final catLabel = category == 'gold'
        ? 'Reseller Gold'
        : category == 'platinum'
            ? 'Reseller Platinum'
            : category == 'premium'
                ? 'Reseller Premium'
                : 'Marketing';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined,
              size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$agentName • $catLabel',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold section title for form sections.
class SalesSectionTitle extends StatelessWidget {
  final String title;
  const SalesSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Payment status dropdown: DP or LUNAS.
class SalesPaymentStatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final bool enableDp;
  final bool enableCod;

  const SalesPaymentStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enableDp = true,
    this.enableCod = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: GoogleFonts.outfit(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'Status Pembayaran',
        labelStyle: GoogleFonts.outfit(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.payment_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1),
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      onChanged: onChanged,
      isExpanded: true,
      items: [
        if (enableDp)
          const DropdownMenuItem(value: 'DP', child: Text('DP (Uang Muka)')),
        if (enableCod)
          const DropdownMenuItem(value: 'COD', child: Text('COD (Bayar di Tempat)')),
        const DropdownMenuItem(
            value: 'LUNAS', child: Text('LUNAS (Bayar Penuh)')),
      ],
    );
  }
}
