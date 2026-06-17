import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Widget untuk merender item progres target (penjualan nominal atau jumlah transaksi).
class BonusProgressTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double current;
  final double target;
  final bool isCurrency;
  final bool isMet;
  final Color accentColor;

  const BonusProgressTile({
    super.key,
    required this.icon,
    required this.label,
    required this.current,
    required this.target,
    required this.isCurrency,
    required this.isMet,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double progress = (current / target).clamp(0.0, 1.0);
    final color = isMet ? AppTheme.primaryColor : accentColor;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCurrency
                        ? '${AppFormatters.currency(current)} / ${AppFormatters.currency(target)}'
                        : '${current.toInt()} / ${target.toInt()} Transaksi',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isMet)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: Container(color: AppTheme.secondaryColor)),
                        Expanded(child: Container(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? const Color(0xFF334155) : Colors.black.withValues(alpha: 0.05),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
