import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaleShippingBadge extends StatelessWidget {
  final String status;

  const SaleShippingBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    final normalizedStatus = status.toUpperCase();
    if (normalizedStatus == 'DISIAPKAN') {
      color = Colors.orange;
    } else if (normalizedStatus == 'DIKIRIM') {
      color = Colors.blue;
    } else if (normalizedStatus == 'SAMPAI') {
      color = Colors.teal;
    } else {
      color = Colors.green; // SELESAI
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            normalizedStatus,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
