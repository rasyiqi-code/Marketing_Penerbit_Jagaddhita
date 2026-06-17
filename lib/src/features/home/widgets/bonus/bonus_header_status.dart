import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Widget untuk merender header status kelayakan bonus.
class BonusHeaderStatus extends StatelessWidget {
  final bool isEligible;
  final bool isBonusLimitReached;

  const BonusHeaderStatus({
    super.key,
    required this.isEligible,
    required this.isBonusLimitReached,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isEligible && !isBonusLimitReached
            ? Colors.green.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isEligible && !isBonusLimitReached
                      ? Icons.verified_rounded
                      : Icons.verified_user_outlined,
                  color: isEligible && !isBonusLimitReached
                      ? Colors.green
                      : AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Kelayakan Bonus',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Periode: ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isBonusLimitReached)
                      Text(
                        'Bonus bulan ini sudah diterima',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.orange[300] : Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (isEligible)
                      Text(
                        'Selamat! Anda berhak klaim bonus.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.green[300] : Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isEligible && !isBonusLimitReached) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Container(height: 2, color: AppTheme.secondaryColor)),
                Expanded(child: Container(height: 2, color: Colors.white)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
