import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/empty_state_widget.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/async_snapshot_widget.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/shared/sale_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/shared/sales_claim_card.dart';

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
        builder: (context, snapshot) => AsyncSnapshotWidget<List<SaleModel>>(
          snapshot: snapshot,
          loadingWidget: limitSales > 20 ? const SizedBox.shrink() : const Center(child: CircularProgressIndicator()),
          isEmpty: (data) => data.isEmpty,
          emptyWidget: const EmptyStateWidget(
            icon: Icons.receipt_long_rounded,
            title: 'Belum Ada Penjualan',
            message: 'Transaksi penjualan Anda akan tercatat di sini.',
          ),
          builder: (context, sales) {
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
        builder: (context, snapshot) => AsyncSnapshotWidget<List<ClaimModel>>(
          snapshot: snapshot,
          isEmpty: (data) => data.isEmpty,
          emptyWidget: const EmptyStateWidget(
            icon: Icons.history_edu_rounded,
            title: 'Belum Ada Penarikan',
            message: 'Riwayat klaim komisi Anda akan ditampilkan di sini.',
          ),
          builder: (context, claims) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: claims.length,
              itemBuilder: (_, i) => SalesClaimCard(claim: claims[i]),
            );
          },
        ),
      ),
    );
  }
}

