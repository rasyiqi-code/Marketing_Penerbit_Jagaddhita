import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:provider/provider.dart';

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
        _monthlySalesCount = monthlyStats['count'] as int;
        _monthlySalesTotal = monthlyStats['total'] as double;
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
        final bool isTargetMet =
            settings.enableMinSalesLimit &&
            (_monthlySalesTotal >= settings.minSaleForPulsa);
        final bool isCountMet =
            settings.enableMinCompletedSalesLimit &&
            (_monthlySalesCount >= settings.minCompletedSalesCount);
        
        // Final eligibility: Must meet at least one ENABLED target
        final bool isEligible = (isTargetMet || isCountMet);
        final bool isBonusLimitReached =
            _userMonthlyBonusCount >= settings.maxPulsaBonusCount;

        final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
              // Header Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isEligible && !isBonusLimitReached
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.05),
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
                        isEligible && !isBonusLimitReached
                            ? Icons.verified_rounded
                            : Icons.verified_user_outlined,
                        color: isEligible && !isBonusLimitReached
                            ? Colors.green
                            : AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Kelayakan Bonus',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Periode: ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (isBonusLimitReached)
                            Text(
                              'Bonus bulan ini sudah diterima',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: isDark ? Colors.orange[300] : Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else if (isEligible)
                            Text(
                              'Selamat! Anda berhak klaim bonus.',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: isDark ? Colors.green[300] : Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (settings.enableMinSalesLimit) ...[
                      _buildProgressItem(
                        icon: Icons.monetization_on_rounded,
                        label: 'Target Penjualan',
                        current: _monthlySalesTotal,
                        target: settings.minSaleForPulsa.toDouble(),
                        isCurrency: true,
                        isMet: isTargetMet,
                        accentColor: AppTheme.primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (settings.enableMinCompletedSalesLimit) ...[
                      _buildProgressItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Jumlah Transaksi',
                        current: _monthlySalesCount.toDouble(),
                        target: settings.minCompletedSalesCount.toDouble(),
                        isCurrency: false,
                        isMet: isCountMet,
                        accentColor: AppTheme.secondaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!settings.enableMinSalesLimit &&
                        !settings.enableMinCompletedSalesLimit)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withValues(alpha: 0.08),
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
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withValues(alpha: 0.05),
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

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required double current,
    required double target,
    required bool isCurrency,
    required bool isMet,
    required Color accentColor,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double progress = (current / target).clamp(0.0, 1.0);
    final color = isMet ? AppTheme.primaryColor : accentColor;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCurrency
                        ? '${AppFormatters.currency(current)} / ${AppFormatters.currency(target)}'
                        : '${current.toInt()} / ${target.toInt()} Transaksi',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isMet)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? const Color(0xFF334155) : Colors.black.withValues(alpha: 0.05),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
