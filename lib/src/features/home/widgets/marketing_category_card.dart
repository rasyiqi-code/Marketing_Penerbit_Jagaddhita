import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MarketingCategoryCard extends StatelessWidget {
  final UserModel user;

  const MarketingCategoryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = user.marketingCategory?.toLowerCase() ?? 'none';
    
    Color primaryColor;
    Color bgColor;
    String categoryName;
    String categoryDesc;
    IconData categoryIcon;

    if (cat == 'gold') {
      primaryColor = Colors.amber.shade700;
      bgColor = isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.shade50;
      categoryName = 'Reseller Gold';
      categoryDesc = 'Anda mendapatkan diskon khusus tingkat pertama dari penjualan paket buku sekolah.';
      categoryIcon = Icons.storefront_rounded;
    } else if (cat == 'platinum') {
      primaryColor = Colors.blueGrey.shade600;
      bgColor = isDark ? Colors.blueGrey.withValues(alpha: 0.15) : Colors.blueGrey.shade50;
      categoryName = 'Reseller Platinum';
      categoryDesc = 'Kategori tingkat menengah. Dapatkan potongan diskon lebih besar dari penjualan paket buku sekolah.';
      categoryIcon = Icons.stars_rounded;
    } else if (cat == 'premium') {
      primaryColor = Colors.grey.shade900;
      bgColor = isDark ? Colors.grey.withValues(alpha: 0.15) : Colors.grey.shade50;
      categoryName = 'Reseller Premium';
      categoryDesc = 'Kategori tertinggi! Dapatkan potongan diskon maksimal untuk penjualan skala besar.';
      categoryIcon = Icons.diamond_rounded;
    } else {
      primaryColor = AppTheme.secondaryColor;
      bgColor = isDark ? AppTheme.secondaryColor.withValues(alpha: 0.15) : AppTheme.secondaryColor.withValues(alpha: 0.05);
      categoryName = 'Kemitraan Umum';
      categoryDesc = 'Hubungi administrator untuk mengajukan upgrade status marketing.';
      categoryIcon = Icons.handshake_outlined;
    }

    return StreamBuilder<GlobalSettingsModel>(
      stream: Provider.of<ProductService>(context, listen: false).getGlobalSettings(),
      builder: (context, snapshot) {
        double activeJagaddhita = 0;
        double activeSibi = 0;
        if (snapshot.hasData) {
          final settings = snapshot.data!;
          if (cat == 'gold') {
            activeJagaddhita = settings.goldCommissionPercentJagaddhita;
            activeSibi = settings.goldCommissionPercentSibi;
          } else if (cat == 'platinum') {
            activeJagaddhita = settings.platinumCommissionPercentJagaddhita;
            activeSibi = settings.platinumCommissionPercentSibi;
          } else if (cat == 'premium') {
            activeJagaddhita = settings.premiumCommissionPercentJagaddhita;
            activeSibi = settings.premiumCommissionPercentSibi;
          } else {
            activeJagaddhita = settings.bonusPercentR1; // fallback
            activeSibi = settings.bonusPercentR1;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
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
                        categoryIcon,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Kategori Kemitraan Aktif',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (activeJagaddhita > 0 || activeSibi > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (activeJagaddhita > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'JGD ${activeJagaddhita.toStringAsFixed(0)}%',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (activeSibi > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SIBI ${activeSibi.toStringAsFixed(0)}%',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryDesc,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat == 'none'
                                ? 'Kirim email pengajuan kemitraan resmi untuk menikmati rate diskon terbaik.'
                                : 'Rate potongan otomatis diaplikasikan di form pemesanan buku.',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
