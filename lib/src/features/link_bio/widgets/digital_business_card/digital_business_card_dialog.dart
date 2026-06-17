import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/digital_business_card/digital_business_card_preview.dart';
/// Fungsi pembantu untuk menampilkan dialog visual Kartu Nama Digital dengan indah.
void showDigitalBusinessCardDialog({
  required BuildContext context,
  required UserModel user,
  required String displayName,
  required String professionalTitle,
  required GlobalKey cardKey,
  required Future<void> Function(BuildContext) onDownload,
}) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: RepaintBoundary(
                key: cardKey,
                child: DigitalBusinessCard(
                  user: user,
                  displayName: displayName,
                  professionalTitle: professionalTitle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await onDownload(context);
                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'Unduh Kartu Nama',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
