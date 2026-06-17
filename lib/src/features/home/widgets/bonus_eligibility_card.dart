import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/bonus/bonus_progress_tile.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/bonus/bonus_header_status.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/bonus/bonus_inactive_section.dart';

class BonusEligibilityCard extends StatefulWidget {
  final String userId;

  const BonusEligibilityCard({super.key, required this.userId});

  @override
  State<BonusEligibilityCard> createState() => _BonusEligibilityCardState();
}

class _BonusEligibilityCardState extends State<BonusEligibilityCard> {
  int _userMonthlyBonusCount = 0;
  int _monthlySalesCount = 0;
  double _monthlySalesTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    if (!mounted) return;
    final salesService = Provider.of<SalesService>(context, listen: false);

    // Fetch stats
    final monthlyBonuses = await salesService.getUserBonusCountThisMonth(
      widget.userId,
    );
    final monthlyStats = await salesService.getUserSalesStatsThisMonth(
      widget.userId,
    );

    if (mounted) {
      setState(() {
        _userMonthlyBonusCount = monthlyBonuses;
        _monthlySalesCount = (monthlyStats['count'] ?? 0).toInt();
        _monthlySalesTotal = (monthlyStats['total'] ?? 0).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GlobalSettingsModel>(
      stream: Provider.of<ProductService>(
        context,
        listen: false,
      ).getGlobalSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final settings = snapshot.data!;
        if (!settings.enableR1PulsaBonus) return const SizedBox.shrink();

        // Calculate eligibility based on ENABLED rules only
        final bool isTargetMet = _monthlySalesTotal >= settings.minSaleForPulsa;
        final bool isCountMet = _monthlySalesCount >= settings.minCompletedSalesCount;
        
        // Final eligibility: Must meet all ENABLED targets. If none enabled, eligible by default (handled by enableR1PulsaBonus above)
        final bool isEligible = (!settings.enableMinSalesLimit || isTargetMet) &&
                                (!settings.enableMinCompletedSalesLimit || isCountMet);
        
        final bool isBonusLimitReached =
            settings.enableMaxPulsaBonusLimit && _userMonthlyBonusCount >= settings.maxPulsaBonusCount;

        final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
              // Header Status kelayakan bonus
              BonusHeaderStatus(
                isEligible: isEligible,
                isBonusLimitReached: isBonusLimitReached,
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (settings.enableMinSalesLimit) ...[
                      BonusProgressTile(
                        icon: Icons.monetization_on_rounded,
                        label: 'Target Penjualan',
                        current: _monthlySalesTotal,
                        target: settings.minSaleForPulsa.toDouble(),
                        isCurrency: true,
                        isMet: isTargetMet,
                        accentColor: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (settings.enableMinCompletedSalesLimit) ...[
                      BonusProgressTile(
                        icon: Icons.receipt_long_rounded,
                        label: 'Jumlah Transaksi',
                        current: _monthlySalesCount.toDouble(),
                        target: settings.minCompletedSalesCount.toDouble(),
                        isCurrency: false,
                        isMet: isCountMet,
                        accentColor: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!settings.enableMinSalesLimit &&
                        !settings.enableMinCompletedSalesLimit)
                      const BonusInactiveSection(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Capai salah satu target di atas untuk klaim bonus pulsa ${AppFormatters.currency(settings.pulsaBonusAmount)}.',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
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
