import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

class SaleStatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const SaleStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    final normalizedStatus = status.toUpperCase();
    if (normalizedStatus == 'LUNAS' || normalizedStatus == 'COMPLETE') {
      color = AppTheme.primaryColor;
    } else if (normalizedStatus == 'COD') {
      color = const Color(0xFF3B82F6);
    } else {
      color = AppTheme.secondaryColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
