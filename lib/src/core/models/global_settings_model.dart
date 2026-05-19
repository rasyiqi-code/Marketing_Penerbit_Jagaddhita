class GlobalSettingsModel {
  final double bonusPercentR1;
  final double minPayout;
  final double pulsaBonusAmount; // Fixed amount for Pulsa Penerbitan
  final double minSaleForPulsa; // Threshold
  final bool enableR1;

  // Reseller and Distributor Commission Settings
  final double resellerCommissionPercent;
  final double distributorCommissionPercent;

  // Progressive Commission Settings
  final double thresholdJagaddhitaMedium;
  final double percentJagaddhitaMedium;
  final double thresholdJagaddhitaHigh;
  final double percentJagaddhitaHigh;
  final double thresholdSibi;
  final double percentSibi;

  // Specific Reward Toggles (Penerbitan only)
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
    this.resellerCommissionPercent = 30.0,
    this.distributorCommissionPercent = 40.0,
    this.thresholdJagaddhitaMedium = 20000000.0,
    this.percentJagaddhitaMedium = 60.0,
    this.thresholdJagaddhitaHigh = 50000000.0,
    this.percentJagaddhitaHigh = 70.0,
    this.thresholdSibi = 10000000.0,
    this.percentSibi = 50.0,
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
      resellerCommissionPercent:
          (data['reseller_commission_percent'] ?? 30.0).toDouble(),
      distributorCommissionPercent:
          (data['distributor_commission_percent'] ?? 40.0).toDouble(),
      thresholdJagaddhitaMedium:
          (data['threshold_jagaddhita_medium'] ?? 20000000.0).toDouble(),
      percentJagaddhitaMedium:
          (data['percent_jagaddhita_medium'] ?? 60.0).toDouble(),
      thresholdJagaddhitaHigh:
          (data['threshold_jagaddhita_high'] ?? 50000000.0).toDouble(),
      percentJagaddhitaHigh:
          (data['percent_jagaddhita_high'] ?? 70.0).toDouble(),
      thresholdSibi: (data['threshold_sibi'] ?? 10000000.0).toDouble(),
      percentSibi: (data['percent_sibi'] ?? 50.0).toDouble(),
      enableR1: data['enable_r1'] ?? true,
      enableR1Commission: data['enable_r1_commission'] ?? true,
      enableR1PulsaBonus: data['enable_r1_pulsa_bonus'] ?? true,
      minPulsaWithdrawal: (data['min_pulsa_withdrawal'] ?? 20000).toDouble(),
      latestInfo: data['latest_info'] ?? 'Batas klaim pulsa bulan ini: Tgl 25.',
      webBaseUrl: data['web_base_url'] ?? 'https://marketing-jagaddhitamp.web.app',
      allowedWithdrawalDays: List<int>.from(
        data['allowed_withdrawal_days'] ?? [1, 2, 3, 4, 5, 6, 7],
      ),
      enableMaxPulsaBonusLimit:
          data['enable_max_pulsa_bonus_limit'] ?? true,
      maxPulsaBonusCount: data['max_pulsa_bonus_count'] ?? 1,
      enableMinCompletedSalesLimit:
          data['enable_min_completed_sales_limit'] ?? false,
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
      'reseller_commission_percent': resellerCommissionPercent,
      'distributor_commission_percent': distributorCommissionPercent,
      'threshold_jagaddhita_medium': thresholdJagaddhitaMedium,
      'percent_jagaddhita_medium': percentJagaddhitaMedium,
      'threshold_jagaddhita_high': thresholdJagaddhitaHigh,
      'percent_jagaddhita_high': percentJagaddhitaHigh,
      'threshold_sibi': thresholdSibi,
      'percent_sibi': percentSibi,
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
