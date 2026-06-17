import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';

/// Hasil kalkulasi nilai-nilai penjualan.
class SalesCalculationResult {
  final double bruto;
  final double discountPercent;
  final double discountAmount;
  final double netto;
  final double commissionAmount;
  final double pulsaBonusAmount;

  const SalesCalculationResult({
    required this.bruto,
    required this.discountPercent,
    required this.discountAmount,
    required this.netto,
    required this.commissionAmount,
    required this.pulsaBonusAmount,
  });
}

/// Helper untuk melakukan perhitungan business logic penjualan (komisi, diskon, bonus pulsa).
class SalesCalculatorHelper {
  /// Mendapatkan persentase komisi/diskon untuk SIBI dan Jagaddhita.
  static Map<String, double> getDiscountPercents({
    required double bruto,
    required GlobalSettingsModel? settings,
    required String? marketingCategory,
    required double monthlySalesTotal,
  }) {
    double percentSibi = settings?.bonusPercentR1 ?? 0;
    double percentJagaddhita = settings?.bonusPercentR1 ?? 0;

    if (settings == null || !settings.enableR1Commission) {
      return {'sibi': 0, 'jagaddhita': 0};
    }

    String method = settings.discountCalculationMethod;
    if (method == 'manual') {
      if (marketingCategory == 'premium') {
        percentSibi = settings.premiumCommissionPercentSibi;
        percentJagaddhita = settings.premiumCommissionPercentJagaddhita;
      } else if (marketingCategory == 'platinum') {
        percentSibi = settings.platinumCommissionPercentSibi;
        percentJagaddhita = settings.platinumCommissionPercentJagaddhita;
      } else if (marketingCategory == 'gold') {
        percentSibi = settings.goldCommissionPercentSibi;
        percentJagaddhita = settings.goldCommissionPercentJagaddhita;
      }
    } else if (method == 'per_transaction') {
      if (bruto >= settings.premiumThreshold) {
        percentSibi = settings.premiumCommissionPercentSibi;
        percentJagaddhita = settings.premiumCommissionPercentJagaddhita;
      } else if (bruto >= settings.platinumThreshold) {
        percentSibi = settings.platinumCommissionPercentSibi;
        percentJagaddhita = settings.platinumCommissionPercentJagaddhita;
      } else if (bruto >= settings.goldThreshold) {
        percentSibi = settings.goldCommissionPercentSibi;
        percentJagaddhita = settings.goldCommissionPercentJagaddhita;
      }
    } else if (method == 'cumulative_monthly') {
      double totalAccumulated = monthlySalesTotal + bruto;
      if (totalAccumulated >= settings.premiumThreshold) {
        percentSibi = settings.premiumCommissionPercentSibi;
        percentJagaddhita = settings.premiumCommissionPercentJagaddhita;
      } else if (totalAccumulated >= settings.platinumThreshold) {
        percentSibi = settings.platinumCommissionPercentSibi;
        percentJagaddhita = settings.platinumCommissionPercentJagaddhita;
      } else if (totalAccumulated >= settings.goldThreshold) {
        percentSibi = settings.goldCommissionPercentSibi;
        percentJagaddhita = settings.goldCommissionPercentJagaddhita;
      }
    }

    return {'sibi': percentSibi, 'jagaddhita': percentJagaddhita};
  }

  /// Menghitung seluruh variabel keuangan transaksi penjualan.
  static SalesCalculationResult calculate({
    required List<ProductModel> selectedProducts,
    required Map<String, int> selectedProductQuantities,
    required GlobalSettingsModel? settings,
    required String? marketingCategory,
    required double monthlySalesTotal,
    required int monthlySalesCount,
    required int userMonthlyBonusCount,
  }) {
    double brutoSibi = 0;
    double brutoJagaddhita = 0;

    for (var p in selectedProducts) {
      final qty = selectedProductQuantities[p.id] ?? 1;
      if (p.isSibi) {
        brutoSibi += p.price * qty;
      } else {
        brutoJagaddhita += p.price * qty;
      }
    }

    final bruto = brutoSibi + brutoJagaddhita;

    final percents = getDiscountPercents(
      bruto: bruto,
      settings: settings,
      marketingCategory: marketingCategory,
      monthlySalesTotal: monthlySalesTotal,
    );

    double discSibi = brutoSibi * (percents['sibi']! / 100);
    double discJagaddhita = brutoJagaddhita * (percents['jagaddhita']! / 100);

    final discountAmount = discSibi + discJagaddhita;
    final discountPercent = bruto > 0 ? (discountAmount / bruto) * 100 : 0.0;
    final netto = bruto - discountAmount;
    final commissionAmount = discountAmount;

    // Pulsa bonus (crossing threshold logic)
    double pulsaBonusAmount = 0;
    if (settings != null && settings.enableR1PulsaBonus) {
      bool limitReached = settings.enableMaxPulsaBonusLimit &&
          userMonthlyBonusCount >= settings.maxPulsaBonusCount;

      if (!limitReached) {
        final target = settings.minSaleForPulsa;
        final crossesNominal = settings.enableMinSalesLimit &&
            monthlySalesTotal < target &&
            (monthlySalesTotal + bruto) >= target;
        final crossesCount = settings.enableMinCompletedSalesLimit &&
            monthlySalesCount < settings.minCompletedSalesCount &&
            (monthlySalesCount + 1) >= settings.minCompletedSalesCount;

        if (crossesNominal || crossesCount) {
          pulsaBonusAmount = settings.pulsaBonusAmount;
        }
      }
    }

    return SalesCalculationResult(
      bruto: bruto,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      netto: netto,
      commissionAmount: commissionAmount,
      pulsaBonusAmount: pulsaBonusAmount,
    );
  }
}
