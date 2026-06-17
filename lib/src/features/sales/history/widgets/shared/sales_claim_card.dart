import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Card untuk menampilkan satu record klaim (komisi / pulsa / markup).
class SalesClaimCard extends StatelessWidget {
  final ClaimModel claim;

  const SalesClaimCard({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (claim.status) {
      case ClaimModel.statusPaid:
        statusColor = AppTheme.primaryColor;
        statusText = 'BERHASIL';
        break;
      case ClaimModel.statusRejected:
        statusColor = AppTheme.secondaryColor;
        statusText = 'DITOLAK';
        break;
      default:
        statusColor = AppTheme.accentColor;
        statusText = 'DIPROSES';
    }

    final isPulsa = claim.type == ClaimModel.typePulsa;
    final isMarkup = claim.type == 'markup';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPulsa
                    ? AppTheme.accentColor.withValues(alpha: 0.15)
                    : isMarkup
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : AppTheme.secondaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPulsa
                    ? Icons.phone_android_rounded
                    : isMarkup
                        ? Icons.trending_up_rounded
                        : Icons.account_balance_rounded,
                color: isPulsa
                    ? AppTheme.accentColor
                    : isMarkup
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPulsa
                        ? 'Klaim Pulsa'
                        : isMarkup
                            ? 'Penarikan Markup'
                            : 'Penarikan Komisi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(claim.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(claim.amount),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
