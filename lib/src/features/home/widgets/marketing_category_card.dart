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

    if (cat == 'reseller') {
      primaryColor = Colors.orange.shade700;
      bgColor = isDark ? Colors.orange.withOpacity(0.15) : Colors.orange.shade50;
      categoryName = 'Reseller Resmi';
      categoryDesc = 'Anda mendapatkan diskon khusus retail dan komisi menarik dari penjualan paket buku sekolah.';
      categoryIcon = Icons.storefront_rounded;
    } else if (cat == 'distributor') {
      primaryColor = Colors.teal.shade700;
      bgColor = isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.shade50;
      categoryName = 'Distributor Utama';
      categoryDesc = 'Kategori tertinggi! Dapatkan potongan diskon maksimal untuk distribusi skala besar ke sekolah-sekolah.';
      categoryIcon = Icons.local_shipping_rounded;
    } else {
      primaryColor = AppTheme.secondaryColor;
      bgColor = isDark ? AppTheme.secondaryColor.withValues(alpha: 0.15) : AppTheme.secondaryColor.withValues(alpha: 0.05);
      categoryName = 'Kemitraan Umum';
      categoryDesc = 'Hubungi administrator untuk mengajukan upgrade status marketing menjadi Reseller atau Distributor.';
      categoryIcon = Icons.handshake_outlined;
    }

    return StreamBuilder<GlobalSettingsModel>(
      stream: Provider.of<ProductService>(context, listen: false).getGlobalSettings(),
      builder: (context, snapshot) {
        double activePercent = 0;
        if (snapshot.hasData) {
          final settings = snapshot.data!;
          if (cat == 'reseller') {
            activePercent = settings.resellerCommissionPercent;
          } else if (cat == 'distributor') {
            activePercent = settings.distributorCommissionPercent;
          } else {
            activePercent = settings.bonusPercentR1; // fallback
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
                            color: Colors.black.withOpacity(0.05),
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
                            'Kategori Kemitraan Aktif Anda',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (activePercent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${activePercent.toStringAsFixed(0)}% OFF',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
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
                                : 'Rate potongan otomatis diaplikasikan di form pemesanan R1 Penerbit.',
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
