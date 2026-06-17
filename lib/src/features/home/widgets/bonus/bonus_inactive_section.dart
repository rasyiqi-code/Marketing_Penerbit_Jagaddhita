import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget yang merender status ketika program bonus dinonaktifkan.
class BonusInactiveSection extends StatelessWidget {
  const BonusInactiveSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.block_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            'Program Bonus Sedang Nonaktif',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Saat ini belum ada target bonus yang aktif.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
