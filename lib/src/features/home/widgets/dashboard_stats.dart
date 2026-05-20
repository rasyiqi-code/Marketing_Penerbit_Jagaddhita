import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

import 'package:provider/provider.dart';

class DashboardStats extends StatelessWidget {
  final String userId;

  const DashboardStats({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context, listen: false);

    return StreamBuilder<List<SaleModel>>(
      stream: salesService.getUserSales(userId),
      builder: (context, snapshot) {
        double totalRevenue = 0; // Status: COMPLETE
        double pendingRevenue = 0; // Status: LUNAS (Komisi Pending)
        double potentialRevenue = 0; // Status: DP (Potensi Bonus)
        int salesCount = 0;

        if (snapshot.hasData) {
          final sales = snapshot.data!;
          salesCount = sales.length;

          for (var sale in sales) {
            final status = sale.paymentStatus.toUpperCase();

            // Total Pendapatan (Ready to withdraw)
            if (status == 'COMPLETE') {
              totalRevenue += sale.commissionAmount;
            }
            // Komisi Pending (Lunas but not Complete)
            else if (status == 'LUNAS') {
              pendingRevenue += sale.commissionAmount;
            }
            // Potensi Bonus (DP only)
            else if (status == 'DP') {
              potentialRevenue += sale.commissionAmount;
            }
          }
        }

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            children: [
              _buildStatCard(
                title: 'Total Pendapatan',
                value: totalRevenue,
                icon: Icons.account_balance_wallet_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Komisi Pending',
                value: pendingRevenue,
                icon: Icons.hourglass_top_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Potensi Bonus',
                value: potentialRevenue,
                icon: Icons.trending_up_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                isCurrency: true,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Jumlah Penjualan',
                value: salesCount.toDouble(),
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

  Widget _buildStatCard({
    required String title,
    required double value,
    required IconData icon,
    required LinearGradient gradient,
    required bool isCurrency,
  }) {
    // Used AppFormatters instead

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isCurrency
                    ? AppFormatters.currency(value)
                    : value.toInt().toString(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
