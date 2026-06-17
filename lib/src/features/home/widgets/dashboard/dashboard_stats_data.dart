import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';

/// Model pembantu untuk menghitung dan menyimpan data statistik dasbor dari daftar transaksi.
class DashboardStatsData {
  final double totalRevenue;
  final double pendingRevenue;
  final double potentialRevenue;
  final int salesCount;

  const DashboardStatsData({
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.potentialRevenue,
    required this.salesCount,
  });

  /// Factory untuk menghitung data statistik dari daftar SaleModel.
  factory DashboardStatsData.fromSales(List<SaleModel> sales) {
    double totalRevenue = 0; // Status: COMPLETE
    double pendingRevenue = 0; // Status: LUNAS (Komisi Pending)
    double potentialRevenue = 0; // Status: DP atau COD (Potensi Bonus)

    for (var sale in sales) {
      final status = sale.paymentStatus.toUpperCase();

      // Total Pendapatan (Ready to withdraw)
      if (status == 'COMPLETE') {
        totalRevenue += sale.commissionAmount;
      }
      // Komisi Pending (Lunas tapi belum Complete)
      else if (status == 'LUNAS') {
        pendingRevenue += sale.commissionAmount;
      }
      // Potensi Bonus (DP & COD)
      else if (status == 'DP' || status == 'COD') {
        potentialRevenue += sale.commissionAmount;
      }
    }

    return DashboardStatsData(
      totalRevenue: totalRevenue,
      pendingRevenue: pendingRevenue,
      potentialRevenue: potentialRevenue,
      salesCount: sales.length,
    );
  }

  /// Factory default dengan nilai awal kosong.
  factory DashboardStatsData.empty() {
    return const DashboardStatsData(
      totalRevenue: 0,
      pendingRevenue: 0,
      potentialRevenue: 0,
      salesCount: 0,
    );
  }
}
