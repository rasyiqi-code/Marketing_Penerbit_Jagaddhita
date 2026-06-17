import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

class SalePaymentInfoRow extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onPelunasan;

  const SalePaymentInfoRow({
    super.key,
    required this.sale,
    required this.onPelunasan,
  });

  @override
  Widget build(BuildContext context) {
    final status = sale.paymentStatus.toUpperCase();
    if (status == 'DP' && sale.paidAmount > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppTheme.secondaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'DP Terbayar: ${AppFormatters.currency(sale.paidAmount)}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onPelunasan,
              icon: const Icon(Icons.payment, size: 14),
              label: Text(
                'Lunasi',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 1,
              ),
            ),
          ],
        ),
      );
    } else if (status == 'COD') {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delivery_dining_outlined, size: 14, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    Text(
                      'Bayar di Tempat (COD)',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onPelunasan,
              icon: const Icon(Icons.payment, size: 14),
              label: Text(
                'Lunasi',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 1,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
