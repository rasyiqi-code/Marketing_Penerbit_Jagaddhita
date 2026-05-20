import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/notification_service.dart' as local;
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/currency_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/product_picker_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/markup_input_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sales_text_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_proof_input.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sales_entry_shared_widgets.dart';

class SalesEntryPenerbitanScreen extends StatefulWidget {
  const SalesEntryPenerbitanScreen({super.key});

  @override
  State<SalesEntryPenerbitanScreen> createState() =>
      _SalesEntryPenerbitanScreenState();
}

class _SalesEntryPenerbitanScreenState
    extends State<SalesEntryPenerbitanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _transactionProofUrl;

  // Agent info (auto-loaded)
  String _agentName = '';
  String? _marketingCategory;

  // Products
  List<ProductModel> _selectedProducts = [];

  // Controllers
  final _unitPriceController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _markupController = TextEditingController();
  final _dpAmountController = TextEditingController();

  String _paymentStatus = 'DP';

  // Calculated values
  double _bruto = 0;
  double _discountPercent = 0;
  double _discountAmount = 0;
  double _netto = 0;
  double _commissionAmount = 0;
  double _pulsaBonusAmount = 0;

  // Monthly stats for bonus threshold
  int _userMonthlyBonusCount = 0;
  int _monthlySalesCount = 0;
  double _monthlySalesTotal = 0;

  GlobalSettingsModel? _settings;
  late Stream<List<ProductModel>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream =
        Provider.of<ProductService>(context, listen: false).getProducts(1);
    _loadSettings();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final salesService = Provider.of<SalesService>(context, listen: false);
    final user = await auth.getCurrentUserDetails();

    if (mounted && user != null) {
      final monthlyBonuses =
          await salesService.getUserBonusCountThisMonth(user.id);
      final monthlyStats =
          await salesService.getUserSalesStatsThisMonth(user.id);

      setState(() {
        _agentName = (user.name != null && user.name!.isNotEmpty)
            ? user.name!
            : user.email.split('@').first;
        _marketingCategory = user.marketingCategory;
        _userMonthlyBonusCount = monthlyBonuses;
        _monthlySalesCount = monthlyStats['count'] as int;
        _monthlySalesTotal = monthlyStats['total'] as double;
      });
      _calculateValues();
    }
  }

  void _loadSettings() {
    final productService =
        Provider.of<ProductService>(context, listen: false);
    productService.getGlobalSettings().listen((settings) {
      if (mounted) {
        setState(() => _settings = settings);
        _calculateValues();
      }
    });
  }

  void _onProductsChanged(List<ProductModel> products) {
    setState(() {
      _selectedProducts = products;
      if (products.isNotEmpty) {
        final totalCatalogPrice =
            products.fold<double>(0, (sum, p) => sum + p.price);
        _unitPriceController.text =
            AppFormatters.formatNumber(totalCatalogPrice);
      }
      _calculateValues();
    });
  }

  // ─── Single source of truth for commission % ───────────────────────────────
  double _getCommissionPercent(double bruto) {
    if (_settings == null) return 0;

    // Base rate by category
    double percent = _settings!.bonusPercentR1;
    if (_marketingCategory == 'reseller') {
      percent = _settings!.resellerCommissionPercent; // default 30%
    } else if (_marketingCategory == 'distributor') {
      percent = _settings!.distributorCommissionPercent; // default 40%
    }

    // Progressive overrides (only if commission is enabled)
    if (!_settings!.enableR1Commission) return 0;

    final hasSibi = _selectedProducts.any((p) => p.isSibi);
    final hasJagaddhita = _selectedProducts.any((p) => p.isJagaddhita);

    if (hasSibi && !hasJagaddhita) {
      // Pure SIBI order — cap at percentSibi if threshold reached
      if (bruto >= _settings!.thresholdSibi) {
        percent = _settings!.percentSibi; // default 50%
      }
    } else {
      // Jagaddhita or mixed order — progressive tiers
      if (bruto >= _settings!.thresholdJagaddhitaHigh) {
        percent = _settings!.percentJagaddhitaHigh; // default 70%
      } else if (bruto >= _settings!.thresholdJagaddhitaMedium) {
        percent = _settings!.percentJagaddhitaMedium; // default 60%
      }
    }

    return percent;
  }

  void _calculateValues() {
    final unitPrice = double.tryParse(
          _unitPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final qty = int.tryParse(_qtyController.text) ?? 1;

    _bruto = unitPrice * qty;
    _discountPercent = _getCommissionPercent(_bruto);
    _discountAmount = _bruto * (_discountPercent / 100);
    _netto = _bruto - _discountAmount;
    _commissionAmount = _discountAmount; // Marketing income = discount they get

    // Pulsa bonus (crossing threshold logic)
    _pulsaBonusAmount = 0;
    if (_settings != null && _settings!.enableR1PulsaBonus) {
      bool limitReached = _settings!.enableMaxPulsaBonusLimit &&
          _userMonthlyBonusCount >= _settings!.maxPulsaBonusCount;

      if (!limitReached) {
        final target = _settings!.minSaleForPulsa;
        final crossesNominal = _settings!.enableMinSalesLimit &&
            _monthlySalesTotal < target &&
            (_monthlySalesTotal + _bruto) >= target;
        final crossesCount = _settings!.enableMinCompletedSalesLimit &&
            _monthlySalesCount < _settings!.minCompletedSalesCount &&
            (_monthlySalesCount + 1) >= _settings!.minCompletedSalesCount;

        if (crossesNominal || crossesCount) {
          _pulsaBonusAmount = _settings!.pulsaBonusAmount;
        }
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih produk terlebih dahulu')),
      );
      return;
    }

    final unitPrice = double.tryParse(
          _unitPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final qty = int.tryParse(_qtyController.text) ?? 0;

    if (unitPrice <= 0 || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga satuan dan jumlah tidak valid')),
      );
      return;
    }

    if (_paymentStatus == 'DP') {
      final dp = double.tryParse(
            _dpAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
      if (dp <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan jumlah DP yang valid')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final salesService =
          Provider.of<SalesService>(context, listen: false);
      final notificationService =
          Provider.of<AppNotificationService>(context, listen: false);
      final user = await auth.getCurrentUserDetails();
      if (user == null) throw Exception('User not found');

      final markupPerQty = int.tryParse(
              _markupController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      final totalMarkup = markupPerQty * qty;

      final paidAmount = _paymentStatus == 'LUNAS'
          ? _bruto
          : (double.tryParse(
                _dpAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0);

      final primaryProduct = _selectedProducts.first;
      final productLabel = _selectedProducts.length == 1
          ? '"${primaryProduct.name}"'
          : '${_selectedProducts.length} produk';

      final sale = SaleModel(
        id: '',
        userId: user.id,
        productId: primaryProduct.id,
        details: {
          'product_name': _selectedProducts.length == 1
              ? primaryProduct.name
              : '${_selectedProducts.length} produk: ${_selectedProducts.map((p) => p.name).join(', ')}',
          'product_price': unitPrice,
          'quantity': qty,
          'product_ids': _selectedProducts.map((p) => p.id).toList(),
          'product_names': _selectedProducts.map((p) => p.name).toList(),
          'product_prices': _selectedProducts.map((p) => p.price).toList(),
          'marketing_category': _marketingCategory ?? 'none',
          'commission_percentage': _discountPercent,
          'discount_amount': _discountAmount,
          'netto': _netto,
          'markup_per_qty': markupPerQty,
          'house_type': 1,
          'agent_name': user.name ?? 'Unknown',
        },
        totalPrice: _bruto,
        paymentStatus: SaleModel.statusPending,
        bonusAmount: 0,
        commissionAmount: _commissionAmount,
        commissionEarned: _commissionAmount.toInt(),
        markupPerQty: markupPerQty,
        totalMarkup: totalMarkup,
        pulsaBonusAmount: _pulsaBonusAmount,
        paidAmount: paidAmount,
        createdAt: DateTime.now(),
        transactionProofUrl: _transactionProofUrl,
      );

      sale.details['requested_status'] = _paymentStatus;

      await salesService.addSale(sale);

      final notification = NotificationModel(
        id: '',
        title: 'Order Buku Baru',
        body:
            '${user.name ?? "Marketing"} order $productLabel. Bruto: ${AppFormatters.currency(_bruto)} | Netto: ${AppFormatters.currency(_netto)}',
        type: NotificationModel.typeInfo,
        recipientId: 'role:admin',
        createdAt: DateTime.now(),
      );
      await notificationService.sendNotification(notification);

      if (mounted) {
        try {
          final localNotif =
              Provider.of<local.NotificationService>(context, listen: false);
          await localNotif.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Order Berhasil!',
            body: 'Bruto ${AppFormatters.currency(_bruto)} | Netto ${AppFormatters.currency(_netto)}',
          );
        } catch (_) {}

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _qtyController.dispose();
    _markupController.dispose();
    _dpAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_checkout_rounded,
                color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Input Penjualan Buku',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Agent Banner ──────────────────────────────────────────────
              if (_agentName.isNotEmpty)
                SalesAgentBanner(
                    agentName: _agentName, category: _marketingCategory),
              const SizedBox(height: 24),

              // ── Produk ────────────────────────────────────────────────────
              SalesSectionTitle('Pilih Produk'),
              const SizedBox(height: 16),
              _buildProductDropdown(color),

              const SizedBox(height: 32),
              const Divider(thickness: 1),
              const SizedBox(height: 32),

              // ── Harga & Qty ───────────────────────────────────────────────
              SalesSectionTitle('Harga & Jumlah'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SalesTextField(
                      controller: _unitPriceController,
                      label: 'Harga Satuan Bruto',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                      inputFormatters: [CurrencyInputFormatter()],
                      onChanged: (_) => _calculateValues(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SalesTextField(
                      controller: _qtyController,
                      label: 'Jumlah',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateValues(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Kalkulasi Card ────────────────────────────────────────────
              SalesCalculationCard(
                color: color,
                marketingCategory: _marketingCategory ?? '',
                bruto: _bruto,
                discountPercent: _discountPercent,
                discountAmount: _discountAmount,
                netto: _netto,
                commissionAmount: _commissionAmount,
                pulsaBonusAmount: _pulsaBonusAmount,
              ),

              const SizedBox(height: 16),

              // ── Markup ────────────────────────────────────────────────────
              MarkupInputField(
                controller: _markupController,
                quantity: int.tryParse(_qtyController.text) ?? 1,
              ),

              const SizedBox(height: 16),

              // ── Status Bayar ──────────────────────────────────────────────
              SalesPaymentStatusDropdown(
                value: _paymentStatus,
                onChanged: (val) => setState(() => _paymentStatus = val!),
              ),

              if (_paymentStatus == 'DP') ...[
                const SizedBox(height: 16),
                SalesTextField(
                  controller: _dpAmountController,
                  label: 'Jumlah DP yang Dibayar',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  inputFormatters: [CurrencyInputFormatter()],
                ),
              ],

              if (_paymentStatus == 'LUNAS') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pembayaran LUNAS. Komisi dihitung otomatis.',
                          style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Bukti Transfer ────────────────────────────────────────────
              SalesSectionTitle('Bukti Transfer'),
              const SizedBox(height: 12),
              TransactionProofInput(
                themeColor: color,
                initialUrl: _transactionProofUrl,
                onProofUploaded: (url) =>
                    setState(() => _transactionProofUrl = url),
              ),

              const SizedBox(height: 48),

              // ── Submit ────────────────────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    shadowColor: color.withValues(alpha: 0.4),
                  ),
                  onPressed:
                      (_isLoading || _transactionProofUrl == null)
                          ? null
                          : _submitSale,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit Order',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Product Dropdown ────────────────────────────────────────────────────

  Widget _buildProductDropdown(Color color) {
    return StreamBuilder<List<ProductModel>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        return ProductPickerField(
          products: products,
          selectedProducts: _selectedProducts,
          onChanged: _onProductsChanged,
          themeColor: color,
        );
      },
    );
  }
}
