class GlobalSettingsModel {
  final double bonusPercentR1;
  final double minPayout;
  final double pulsaBonusAmount; // Fixed amount for Pulsa Penjualan Buku
  final double minSaleForPulsa; // Threshold
  final bool enableR1;

  // Tier & Discount Settings
  final String discountCalculationMethod; // 'manual', 'per_transaction', 'cumulative_monthly'
  
  // Jagaddhita Percentages
  final double goldCommissionPercentJagaddhita;
  final double platinumCommissionPercentJagaddhita;
  final double premiumCommissionPercentJagaddhita;

  // SIBI Percentages
  final double goldCommissionPercentSibi;
  final double platinumCommissionPercentSibi;
  final double premiumCommissionPercentSibi;

  final double goldThreshold;
  final double platinumThreshold;
  final double premiumThreshold;

  // Specific Reward Toggles (Penjualan Buku only)
  final bool enableR1Commission;
  final bool enableR1PulsaBonus;

  // Announcement
  final String latestInfo;
  final String webBaseUrl;

  final double minPulsaWithdrawal;

  // Bonus Limits
  final bool enableMaxPulsaBonusLimit;
  final int maxPulsaBonusCount;
  final bool enableMinCompletedSalesLimit;
  final int minCompletedSalesCount;
  final bool enableMinSalesLimit;

  // Withdrawal Schedule
  final List<int> allowedWithdrawalDays; // 1 = Mon, 7 = Sun

  GlobalSettingsModel({
    required this.bonusPercentR1,
    required this.minPayout,
    this.pulsaBonusAmount = 50000.0,
    this.minSaleForPulsa = 10000000.0,
    this.discountCalculationMethod = 'manual',
    this.goldCommissionPercentJagaddhita = 30.0,
    this.platinumCommissionPercentJagaddhita = 40.0,
    this.premiumCommissionPercentJagaddhita = 50.0,
    this.goldCommissionPercentSibi = 25.0,
    this.platinumCommissionPercentSibi = 35.0,
    this.premiumCommissionPercentSibi = 45.0,
    this.goldThreshold = 100000.0,
    this.platinumThreshold = 3000000.0,
    this.premiumThreshold = 25000000.0,
    this.minPulsaWithdrawal = 20000.0,
    this.enableR1 = true,
    this.enableR1Commission = true,
    this.enableR1PulsaBonus = true,
    this.latestInfo = 'Batas klaim pulsa bulan ini: Tgl 25.',
    this.webBaseUrl = 'https://marketing-jagaddhitamp.web.app',
    this.allowedWithdrawalDays = const [1, 2, 3, 4, 5, 6, 7],
    this.enableMaxPulsaBonusLimit = true,
    this.maxPulsaBonusCount = 1,
    this.enableMinCompletedSalesLimit = false,
    this.minCompletedSalesCount = 5,
    this.enableMinSalesLimit = true,
  });

  factory GlobalSettingsModel.fromMap(Map<String, dynamic> data) {
    return GlobalSettingsModel(
      bonusPercentR1: (data['bonus_percent_r1'] ?? 0).toDouble(),
      minPayout: (data['min_payout'] ?? 5000000).toDouble(),
      pulsaBonusAmount: (data['pulsa_bonus_amount'] ?? 50000).toDouble(),
      minSaleForPulsa: (data['min_sale_for_pulsa'] ?? 10000000).toDouble(),
      discountCalculationMethod: data['discount_calculation_method'] ?? 'manual',
      // Fallback to old 'gold_commission_percent' if jagaddhita specific one is missing
      goldCommissionPercentJagaddhita: (data['gold_commission_percent_jagaddhita'] ?? data['gold_commission_percent'] ?? 30.0).toDouble(),
      platinumCommissionPercentJagaddhita: (data['platinum_commission_percent_jagaddhita'] ?? data['platinum_commission_percent'] ?? 40.0).toDouble(),
      premiumCommissionPercentJagaddhita: (data['premium_commission_percent_jagaddhita'] ?? data['premium_commission_percent'] ?? 50.0).toDouble(),
      goldCommissionPercentSibi: (data['gold_commission_percent_sibi'] ?? 25.0).toDouble(),
      platinumCommissionPercentSibi: (data['platinum_commission_percent_sibi'] ?? 35.0).toDouble(),
      premiumCommissionPercentSibi: (data['premium_commission_percent_sibi'] ?? 45.0).toDouble(),
      goldThreshold: (data['gold_threshold'] ?? 100000.0).toDouble(),
      platinumThreshold: (data['platinum_threshold'] ?? 3000000.0).toDouble(),
      premiumThreshold: (data['premium_threshold'] ?? 25000000.0).toDouble(),
      enableR1: data['enable_r1'] ?? true,
      enableR1Commission: data['enable_r1_commission'] ?? true,
      enableR1PulsaBonus: data['enable_r1_pulsa_bonus'] ?? true,
      minPulsaWithdrawal: (data['min_pulsa_withdrawal'] ?? 20000).toDouble(),
      latestInfo: data['latest_info'] ?? 'Batas klaim pulsa bulan ini: Tgl 25.',
      webBaseUrl: data['web_base_url'] ?? 'https://marketing-jagaddhitamp.web.app',
      allowedWithdrawalDays: List<int>.from(
        data['allowed_withdrawal_days'] ?? [1, 2, 3, 4, 5, 6, 7],
      ),
      enableMaxPulsaBonusLimit: data['enable_max_pulsa_bonus_limit'] ?? true,
      maxPulsaBonusCount: data['max_pulsa_bonus_count'] ?? 1,
      enableMinCompletedSalesLimit: data['enable_min_completed_sales_limit'] ?? false,
      minCompletedSalesCount: data['min_completed_sales_count'] ?? 5,
      enableMinSalesLimit: data['enable_min_sales_limit'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bonus_percent_r1': bonusPercentR1,
      'min_payout': minPayout,
      'pulsa_bonus_amount': pulsaBonusAmount,
      'min_sale_for_pulsa': minSaleForPulsa,
      'discount_calculation_method': discountCalculationMethod,
      'gold_commission_percent_jagaddhita': goldCommissionPercentJagaddhita,
      'platinum_commission_percent_jagaddhita': platinumCommissionPercentJagaddhita,
      'premium_commission_percent_jagaddhita': premiumCommissionPercentJagaddhita,
      'gold_commission_percent_sibi': goldCommissionPercentSibi,
      'platinum_commission_percent_sibi': platinumCommissionPercentSibi,
      'premium_commission_percent_sibi': premiumCommissionPercentSibi,
      'gold_threshold': goldThreshold,
      'platinum_threshold': platinumThreshold,
      'premium_threshold': premiumThreshold,
      'enable_r1': enableR1,
      'enable_r1_commission': enableR1Commission,
      'enable_r1_pulsa_bonus': enableR1PulsaBonus,
      'min_pulsa_withdrawal': minPulsaWithdrawal,
      'latest_info': latestInfo,
      'web_base_url': webBaseUrl,
      'allowed_withdrawal_days': allowedWithdrawalDays,
      'enable_max_pulsa_bonus_limit': enableMaxPulsaBonusLimit,
      'max_pulsa_bonus_count': maxPulsaBonusCount,
      'enable_min_completed_sales_limit': enableMinCompletedSalesLimit,
      'min_completed_sales_count': minCompletedSalesCount,
      'enable_min_sales_limit': enableMinSalesLimit,
    };
  }
}
