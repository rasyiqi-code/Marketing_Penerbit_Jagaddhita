import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/laporan_excel_exporter.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/history/history_tab_widgets.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/pelunasan_dialog.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/history/widgets/sale_detail_sheet.dart';
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
    dynamic file,
    double remainingAmount,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final salesService = Provider.of<SalesService>(context, listen: false);
      final notifService = Provider.of<FirestoreNotificationService>(context, listen: false);

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
        content: Text('Pelunasan berhasil dikirim! Menunggu verifikasi admin.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
                  const SnackBar(
                      content: Text('Mengekspor laporan penjualan ke Excel...')),
                );
                try {
                  final list = await salesService
                      .getUserSales(_userId!, limit: 500)
                      .first;
                  if (list.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Tidak ada data penjualan untuk diekspor')),
                    );
                    return;
                  }
                  final fileDate =
                      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
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
            SalesTab(
              stream: salesService.getUserSales(_userId!, limit: _limitSales),
              scrollController: _scrollController,
              limitSales: _limitSales,
              onShowDetail: (sale) => showSaleDetailModal(context, sale),
              onPelunasan: _showPelunasanDialog,
            ),
            ClaimsTab(
              stream: walletService.getUserClaims(_userId!),
            ),
          ],
        ),
      ),
    );
  }
}
