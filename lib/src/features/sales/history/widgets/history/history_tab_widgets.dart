import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sale_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sales_claim_card.dart';

/// Tab penjualan dengan infinite scroll dan StreamBuilder.
class SalesTab extends StatelessWidget {
  final Stream<List<SaleModel>> stream;
  final ScrollController scrollController;
  final int limitSales;
  final void Function(SaleModel) onShowDetail;
  final Future<void> Function(SaleModel) onPelunasan;

  const SalesTab({
    super.key,
    required this.stream,
    required this.scrollController,
    required this.limitSales,
    required this.onShowDetail,
    required this.onPelunasan,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<List<SaleModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              limitSales == 20) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return const HistoryEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Belum Ada Penjualan',
              message: 'Transaksi penjualan Anda akan tercatat di sini.',
            );
          }

          return ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sales.length + 1,
            itemBuilder: (_, i) {
              if (i == sales.length) {
                return limitSales > sales.length
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
              }
              final sale = sales[i];
              return SaleCard(
                sale: sale,
                onTap: () => onShowDetail(sale),
                onPelunasan: () => onPelunasan(sale),
              );
            },
          );
        },
      ),
    );
  }
}

/// Tab penarikan (claims) dengan StreamBuilder.
class ClaimsTab extends StatelessWidget {
  final Stream<List<ClaimModel>> stream;
  const ClaimsTab({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<List<ClaimModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final claims = snapshot.data ?? [];

          if (claims.isEmpty) {
            return const HistoryEmptyState(
              icon: Icons.history_edu_rounded,
              title: 'Belum Ada Penarikan',
              message: 'Riwayat klaim komisi Anda akan ditampilkan di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: claims.length,
            itemBuilder: (_, i) => SalesClaimCard(claim: claims[i]),
          );
        },
      ),
    );
  }
}

/// Empty state generik untuk tab riwayat.
class HistoryEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const HistoryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.01),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
                child: Icon(icon, size: 48, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
