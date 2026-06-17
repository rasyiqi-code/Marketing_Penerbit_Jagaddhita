import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/laporan_excel_exporter.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/transaction/transaction_card.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _limit = 20;
  bool _isLoadingMore = false;
  String? _selectedStatus; // null = All


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        // Load more
        setState(() {
          _limit += 20;
          _isLoadingMore = true; // Debounce slightly
        });
        // Reset debounce after a bit to allow next load if stream updates
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Daftar Transaksi';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Export Excel',
            onPressed: () async {
              final salesService = Provider.of<SalesService>(context, listen: false);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Mengekspor semua transaksi ke Excel...')),
              );
              try {
                final list = await salesService.getSales(
                  houseType: 1,
                  status: _selectedStatus,
                  limit: 1000,
                ).first;
                
                if (list.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Tidak ada transaksi untuk diekspor')),
                  );
                  return;
                }
                
                final fileDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                await LaporanExcelExporter.exportSalesToExcel(
                  list,
                  fileName: 'Laporan_Admin_Penjualan_$fileDate.xlsx',
                  isAdmin: true,
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Gagal mengekspor Excel: $e')),
                );
              }
            },
          ),
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() {
              _selectedStatus = value;
              _limit = 20; // Reset limit on filter change
            }),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Tampilkan Semua')),
              const PopupMenuItem(
                value: SaleModel.statusPending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: SaleModel.statusDp,
                child: Text('DP Only'),
              ),
              const PopupMenuItem(
                value: SaleModel.statusLunas,
                child: Text('Lunas'),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: StreamBuilder<List<SaleModel>>(
          key: ValueKey<String>('sales_stream_${_selectedStatus ?? "all"}'),
          stream: Provider.of<SalesService>(context).getSales(
            houseType: 1, // Penjualan Buku
            status: _selectedStatus,
            limit: _limit,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Only show full loading on first load
              if (_limit == 20) {
                return const Center(child: CircularProgressIndicator());
              }
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final sales = snapshot.data ?? [];

            if (sales.isEmpty) {
              // ... Empty view code unchanged
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant, // Colors.grey[300]
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada transaksi nih',
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: sales.length + 1, // +1 for loading indicator at bottom
              itemBuilder: (context, index) {
                if (index == sales.length) {
                  // Bottom Loader
                  return _limit > sales.length
                      ? const SizedBox.shrink() // End of list probably
                      : const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                }
                final sale = sales[index];
                return TransactionCard(sale: sale);
              },
            );
          },
        ),
      ),
    );
  }
}

