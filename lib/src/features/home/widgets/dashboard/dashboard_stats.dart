import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/dashboard/dashboard_stats_data.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/dashboard/dashboard_stat_card.dart';

class DashboardStats extends StatelessWidget {
  final String userId;

  const DashboardStats({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context, listen: false);

    return StreamBuilder<List<SaleModel>>(
      stream: salesService.getUserSales(userId),
      builder: (context, snapshot) {
        final stats = snapshot.hasData
            ? DashboardStatsData.fromSales(snapshot.data!)
            : DashboardStatsData.empty();

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            children: [
              DashboardStatCard(
                title: 'Total Pendapatan',
                value: stats.totalRevenue,
                icon: Icons.account_balance_wallet_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              DashboardStatCard(
                title: 'Komisi Pending',
                value: stats.pendingRevenue,
                icon: Icons.hourglass_top_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              DashboardStatCard(
                title: 'Potensi Bonus',
                value: stats.potentialRevenue,
                icon: Icons.trending_up_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              DashboardStatCard(
                title: 'Jumlah Penjualan',
                value: stats.salesCount.toDouble(),
                icon: Icons.receipt_long_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
