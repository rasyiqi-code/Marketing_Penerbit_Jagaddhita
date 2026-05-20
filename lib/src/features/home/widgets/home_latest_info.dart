import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:provider/provider.dart';

class HomeLatestInfo extends StatelessWidget {
  const HomeLatestInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GlobalSettingsModel>(
      stream: Provider.of<ProductService>(
        context,
        listen: false,
      ).getGlobalSettings(),
      builder: (context, settingsSnapshot) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final infoText = settingsSnapshot.data?.latestInfo ?? 'Batas klaim pulsa bulan ini: Tgl 25.';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Info Terkini',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(isDark ? 0.05 : 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      infoText,
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
