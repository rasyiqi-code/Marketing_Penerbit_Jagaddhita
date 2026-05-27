import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/laporan_excel_exporter.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/pelunasan_dialog.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sale_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sale_detail_sheet.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sales_claim_card.dart';
import 'package:provider/provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String? _userId;
  final _scrollController = ScrollController();
  int _limitSales = 20;
  bool _isLoadingSales = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && !_isLoadingSales) {
      setState(() {
        _limitSales += 20;
        _isLoadingSales = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isLoadingSales = false);
      });
    }
  }

  Future<void> _loadUser() async {
    final user = await Provider.of<AuthService>(context, listen: false)
        .getCurrentUserDetails();
    if (mounted && user != null) setState(() => _userId = user.id);
  }

  // ── Pelunasan flow ─────────────────────────────────────────────────────────

  Future<void> _showPelunasanDialog(SaleModel sale) async {
    final remaining = sale.totalPrice - sale.paidAmount;
    await showDialog(
      context: context,
      builder: (_) => PelunasanDialog(
        remainingAmount: remaining,
        onConfirm: (file) async {
          Navigator.pop(context);
          await _processPelunasan(sale, file, remaining);
        },
      ),
    );
  }

  Future<void> _processPelunasan(
    SaleModel sale,
    XFile file,
    double remainingAmount,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final salesService = Provider.of<SalesService>(context, listen: false);
      final notifService =
          Provider.of<AppNotificationService>(context, listen: false);

      final bytes = await file.readAsBytes();
      final filename =
          'pelunasan_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final url =
          await storage.uploadBytes(bytes, filename, 'transaction_proofs');

      if (!mounted) return;

      await salesService.updateSaleStatus(
        sale,
        SaleModel.statusLunas,
        note: 'Pelunasan by Marketing via App',
        actor: 'Marketing',
        extraData: {
          'transaction_proof_url': url,
          'paid_amount': sale.totalPrice,
        },
      );

      await notifService.sendNotification(NotificationModel(
        id: '',
        title: 'Bukti Pelunasan Baru',
        body:
            'Marketing upload bukti pelunasan #${sale.id.substring(0, 8).toUpperCase()}',
        type: NotificationModel.typeInfo,
        recipientId: 'role:admin',
        relatedId: sale.id,
        createdAt: DateTime.now(),
      ));

      messenger.showSnackBar(const SnackBar(
        content:
            Text('Pelunasan berhasil dikirim! Menunggu verifikasi admin.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final salesService = Provider.of<SalesService>(context);
    final walletService = Provider.of<WalletService>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Aktivitas'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.description_outlined),
              tooltip: 'Export Excel',
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Mengekspor laporan penjualan ke Excel...')),
                );
                try {
                  final list = await salesService.getUserSales(_userId!, limit: 500).first;
                  if (list.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Tidak ada data penjualan untuk diekspor')),
                    );
                    return;
                  }
                  final fileDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                  await LaporanExcelExporter.exportSalesToExcel(
                    list,
                    fileName: 'Laporan_Penjualan_$fileDate.xlsx',
                    isAdmin: false,
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Gagal mengekspor Excel: $e')),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Penjualan'),
              Tab(text: 'Penarikan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SalesTab(
              stream: salesService.getUserSales(_userId!, limit: _limitSales),
              scrollController: _scrollController,
              limitSales: _limitSales,
              onShowDetail: (sale) => showSaleDetailModal(context, sale),
              onPelunasan: _showPelunasanDialog,
            ),
            _ClaimsTab(
              stream: walletService.getUserClaims(_userId!),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab widgets ────────────────────────────────────────────────────────────────

class _SalesTab extends StatelessWidget {
  final Stream<List<SaleModel>> stream;
  final ScrollController scrollController;
  final int limitSales;
  final void Function(SaleModel) onShowDetail;
  final Future<void> Function(SaleModel) onPelunasan;

  const _SalesTab({
    required this.stream,
    required this.scrollController,
    required this.limitSales,
    required this.onShowDetail,
    required this.onPelunasan,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SaleModel>>(
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
          return _EmptyState(
            icon: Icons.receipt_long_rounded,
            message: 'Belum ada penjualan',
          );
        }

        return ListView.builder(
          controller: scrollController,
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
    );
  }
}

class _ClaimsTab extends StatelessWidget {
  final Stream<List<ClaimModel>> stream;
  const _ClaimsTab({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClaimModel>>(
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
          return _EmptyState(
            icon: Icons.history_edu_rounded,
            message: 'Belum ada riwayat penarikan',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: claims.length,
          itemBuilder: (_, i) => SalesClaimCard(claim: claims[i]),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
