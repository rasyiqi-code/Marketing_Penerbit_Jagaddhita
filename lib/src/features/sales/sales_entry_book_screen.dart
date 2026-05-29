import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/customer_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/customer_service.dart';
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

class SalesEntryBookScreen extends StatefulWidget {
  const SalesEntryBookScreen({super.key});

  @override
  State<SalesEntryBookScreen> createState() =>
      _SalesEntryBookScreenState();
}

class _SalesEntryBookScreenState
    extends State<SalesEntryBookScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _transactionProofUrl;

  // Agent info (auto-loaded)
  String _agentName = '';
  String? _marketingCategory;

  // Products & Quantities
  List<ProductModel> _selectedProducts = [];
  Map<String, int> _selectedProductQuantities = {};

  // Customer Autocomplete
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _showCustomerSuggestions = false;

  // Controllers
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
    final customerService = Provider.of<CustomerService>(context, listen: false);
    final user = await auth.getCurrentUserDetails();

    if (mounted && user != null) {
      final monthlyBonuses =
          await salesService.getUserBonusCountThisMonth(user.id);
      final monthlyStats =
          await salesService.getUserSalesStatsThisMonth(user.id);

      // Listen to agent's customers list
      customerService.getCustomers(user.id).listen((customers) {
        if (mounted) {
          setState(() {
            _allCustomers = customers;
          });
        }
      });

      setState(() {
        _agentName = (user.name != null && user.name!.isNotEmpty)
            ? user.name!
            : user.email.split('@').first;
        _marketingCategory = user.marketingCategory;
        _userMonthlyBonusCount = monthlyBonuses;
        _monthlySalesCount = (monthlyStats['count'] ?? 0).toInt();
        _monthlySalesTotal = (monthlyStats['total'] ?? 0).toDouble();
      });
      _calculateValues();
    }
  }

  void _loadSettings() {
    final productService =
        Provider.of<ProductService>(context, listen: false);
    productService.getGlobalSettings().listen((settings) {
      if (mounted) {
        setState(() {
          _settings = settings;
          
          // Fallback logic if the current _paymentStatus is disabled
          if (_paymentStatus == 'DP' && !settings.enablePaymentDP) {
            _paymentStatus = settings.enablePaymentCOD ? 'COD' : 'LUNAS';
          } else if (_paymentStatus == 'COD' && !settings.enablePaymentCOD) {
            _paymentStatus = settings.enablePaymentDP ? 'DP' : 'LUNAS';
          }
        });
        _calculateValues();
      }
    });
  }

  void _onProductsChanged(List<ProductModel> products) {
    setState(() {
      _selectedProducts = products;
      // Sync quantities: retain existing quantities, default new ones to 1
      final syncedQuantities = <String, int>{};
      for (var p in products) {
        syncedQuantities[p.id] = _selectedProductQuantities[p.id] ?? 1;
      }
      _selectedProductQuantities = syncedQuantities;
      _calculateValues();
    });
  }

  void _onCustomerNameChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredCustomers = [];
        _showCustomerSuggestions = false;
      });
      return;
    }

    final filtered = _allCustomers.where((c) {
      return c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.phoneNumber.contains(query);
    }).toList();

    setState(() {
      _filteredCustomers = filtered;
      _showCustomerSuggestions = filtered.isNotEmpty;
    });
  }

  // ─── Discount Calculation Logic ───────────────────────────────
  Map<String, double> _getDiscountPercents(double bruto) {
    double percentSibi = _settings?.bonusPercentR1 ?? 0;
    double percentJagaddhita = _settings?.bonusPercentR1 ?? 0;

    if (_settings == null || !_settings!.enableR1Commission) {
      return {'sibi': 0, 'jagaddhita': 0};
    }

    String method = _settings!.discountCalculationMethod;
    if (method == 'manual') {
      if (_marketingCategory == 'premium') {
        percentSibi = _settings!.premiumCommissionPercentSibi;
        percentJagaddhita = _settings!.premiumCommissionPercentJagaddhita;
      } else if (_marketingCategory == 'platinum') {
        percentSibi = _settings!.platinumCommissionPercentSibi;
        percentJagaddhita = _settings!.platinumCommissionPercentJagaddhita;
      } else if (_marketingCategory == 'gold') {
        percentSibi = _settings!.goldCommissionPercentSibi;
        percentJagaddhita = _settings!.goldCommissionPercentJagaddhita;
      }
    } else if (method == 'per_transaction') {
      if (bruto >= _settings!.premiumThreshold) {
        percentSibi = _settings!.premiumCommissionPercentSibi;
        percentJagaddhita = _settings!.premiumCommissionPercentJagaddhita;
      } else if (bruto >= _settings!.platinumThreshold) {
        percentSibi = _settings!.platinumCommissionPercentSibi;
        percentJagaddhita = _settings!.platinumCommissionPercentJagaddhita;
      } else if (bruto >= _settings!.goldThreshold) {
        percentSibi = _settings!.goldCommissionPercentSibi;
        percentJagaddhita = _settings!.goldCommissionPercentJagaddhita;
      }
    } else if (method == 'cumulative_monthly') {
      double totalAccumulated = _monthlySalesTotal + bruto;
      if (totalAccumulated >= _settings!.premiumThreshold) {
        percentSibi = _settings!.premiumCommissionPercentSibi;
        percentJagaddhita = _settings!.premiumCommissionPercentJagaddhita;
      } else if (totalAccumulated >= _settings!.platinumThreshold) {
        percentSibi = _settings!.platinumCommissionPercentSibi;
        percentJagaddhita = _settings!.platinumCommissionPercentJagaddhita;
      } else if (totalAccumulated >= _settings!.goldThreshold) {
        percentSibi = _settings!.goldCommissionPercentSibi;
        percentJagaddhita = _settings!.goldCommissionPercentJagaddhita;
      }
    }

    return {'sibi': percentSibi, 'jagaddhita': percentJagaddhita};
  }

  void _calculateValues() {
    double brutoSibi = 0;
    double brutoJagaddhita = 0;

    for (var p in _selectedProducts) {
      final qty = _selectedProductQuantities[p.id] ?? 1;
      if (p.isSibi) {
        brutoSibi += p.price * qty;
      } else {
        brutoJagaddhita += p.price * qty;
      }
    }

    _bruto = brutoSibi + brutoJagaddhita;

    final percents = _getDiscountPercents(_bruto);
    double discSibi = brutoSibi * (percents['sibi']! / 100);
    double discJagaddhita = brutoJagaddhita * (percents['jagaddhita']! / 100);

    _discountAmount = discSibi + discJagaddhita;
    _discountPercent = _bruto > 0 ? (_discountAmount / _bruto) * 100 : 0;
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

    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nama customer')),
      );
      return;
    }
    if (customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nomor HP customer')),
      );
      return;
    }

    final totalQty = _selectedProductQuantities.values.fold<int>(0, (sum, q) => sum + q);

    if (_bruto <= 0 || totalQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga total dan jumlah tidak valid')),
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
      final salesService = Provider.of<SalesService>(context, listen: false);
      final customerService = Provider.of<CustomerService>(context, listen: false);
      final notificationService = Provider.of<AppNotificationService>(context, listen: false);
      
      final user = await auth.getCurrentUserDetails();
      if (user == null) throw Exception('User not found');

      final markupPerQty = int.tryParse(
              _markupController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      final totalMarkup = markupPerQty * totalQty;

      final paidAmount = _paymentStatus == 'LUNAS'
          ? _bruto
          : (_paymentStatus == 'COD' 
              ? 0.0
              : (double.tryParse(
                    _dpAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0));

      // Save customer to custom database if they are new
      await customerService.saveCustomerIfNew(user.id, customerName, customerPhone);

      final primaryProduct = _selectedProducts.first;
      final productSummaryList = _selectedProducts.map((p) {
        final q = _selectedProductQuantities[p.id] ?? 1;
        return '${p.name} (x$q)';
      }).join(', ');

      final productLabel = _selectedProducts.length == 1
          ? '"${primaryProduct.name} (x${_selectedProductQuantities[primaryProduct.id] ?? 1})"'
          : '${_selectedProducts.length} judul buku ($totalQty eks)';

      final sale = SaleModel(
        id: '',
        userId: user.id,
        productId: primaryProduct.id,
        details: {
          'product_name': _selectedProducts.length == 1
              ? '${primaryProduct.name} (x${_selectedProductQuantities[primaryProduct.id] ?? 1})'
              : '${_selectedProducts.length} judul buku: $productSummaryList',
          'product_price': primaryProduct.price,
          'quantity': totalQty,
          'product_ids': _selectedProducts.map((p) => p.id).toList(),
          'product_names': _selectedProducts.map((p) => p.name).toList(),
          'product_prices': _selectedProducts.map((p) => p.price).toList(),
          'product_quantities': _selectedProducts.map((p) => _selectedProductQuantities[p.id] ?? 1).toList(),
          'customer_name': customerName,
          'customer_phone': customerPhone,
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
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _markupController.dispose();
    _dpAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.primaryColor;
    final totalQty = _selectedProductQuantities.values.fold<int>(0, (sum, q) => sum + q);

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Row(
            children: [
              Expanded(child: Container(height: 4, color: AppTheme.secondaryColor)),
              Expanded(child: Container(height: 4, color: Colors.white)),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _settings != null && !_settings!.enableR1
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Input Penjualan Ditangguhkan',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Penginputan laporan penjualan buku saat ini dinonaktifkan oleh administrator.',
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Agent Banner ──────────────────────────────────────────────
                    if (_agentName.isNotEmpty)
                      SalesAgentBanner(
                          agentName: _agentName, category: _marketingCategory),
                    const SizedBox(height: 10),

                    // ── Customer Info ─────────────────────────────────────────────
                    SalesSectionTitle('Informasi Pelanggan'),
                    const SizedBox(height: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SalesTextField(
                              controller: _customerNameController,
                              label: 'Nama Customer',
                              icon: Icons.person_outline_rounded,
                              onChanged: _onCustomerNameChanged,
                            ),
                            const SizedBox(height: 10),
                            SalesTextField(
                              controller: _customerPhoneController,
                              label: 'Nomor HP Customer',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                        if (_showCustomerSuggestions)
                          Positioned(
                            top: 50,
                            left: 0,
                            right: 0,
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(10),
                              shadowColor: Colors.black26,
                              color: Theme.of(context).cardColor,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _filteredCustomers.length,
                                  separatorBuilder: (ctx, idx) => const Divider(height: 1),
                                  itemBuilder: (ctx, idx) {
                                    final customer = _filteredCustomers[idx];
                                    return ListTile(
                                      dense: true,
                                      leading: const CircleAvatar(
                                        radius: 14,
                                        child: Icon(Icons.person, size: 14),
                                      ),
                                      title: Text(
                                        customer.name,
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        customer.phoneNumber,
                                        style: GoogleFonts.outfit(fontSize: 11),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _customerNameController.text = customer.name;
                                          _customerPhoneController.text = customer.phoneNumber;
                                          _showCustomerSuggestions = false;
                                          _filteredCustomers = [];
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),

                    // ── Produk ────────────────────────────────────────────────────
                    SalesSectionTitle('Pilih Produk'),
                    const SizedBox(height: 8),
                    _buildProductDropdown(color),

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),

                    // ── Selected Books List (Itemized Steppers) ───────────────────
                    if (_selectedProducts.isNotEmpty) ...[
                      SalesSectionTitle('Daftar Buku Yang Dipesan'),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedProducts.length,
                        itemBuilder: (ctx, idx) {
                          final product = _selectedProducts[idx];
                          final qty = _selectedProductQuantities[product.id] ?? 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (product.isSibi ? Colors.indigo : AppTheme.primaryColor)
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (product.isSibi ? Colors.indigo : AppTheme.primaryColor)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    product.isSibi ? Icons.account_balance : Icons.menu_book_rounded,
                                    color: product.isSibi ? Colors.indigo : AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${AppFormatters.currency(product.price)} • ${product.category}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                                      onPressed: qty > 1
                                          ? () {
                                              setState(() {
                                                _selectedProductQuantities[product.id] = qty - 1;
                                                _calculateValues();
                                              });
                                            }
                                          : null,
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 24),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$qty',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 22),
                                      onPressed: () {
                                        setState(() {
                                          _selectedProductQuantities[product.id] = qty + 1;
                                          _calculateValues();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 1),
                      const SizedBox(height: 12),
                    ],

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

                    const SizedBox(height: 10),

                    // ── Markup ────────────────────────────────────────────────────
                    MarkupInputField(
                      controller: _markupController,
                      quantity: totalQty > 0 ? totalQty : 1,
                    ),

                    const SizedBox(height: 10),

                    // ── Status Bayar ──────────────────────────────────────────────
                    SalesPaymentStatusDropdown(
                      value: _paymentStatus,
                      enableDp: _settings?.enablePaymentDP ?? true,
                      enableCod: _settings?.enablePaymentCOD ?? true,
                      onChanged: (val) => setState(() => _paymentStatus = val!),
                    ),

                    if (_paymentStatus == 'DP') ...[
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 6),
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

                    const SizedBox(height: 12),

                    // ── Bukti Transfer ────────────────────────────────────────────
                    SalesSectionTitle('Bukti Transfer'),
                    const SizedBox(height: 8),
                    TransactionProofInput(
                      themeColor: color,
                      initialUrl: _transactionProofUrl,
                      onProofUploaded: (url) =>
                          setState(() => _transactionProofUrl = url),
                    ),

                    const SizedBox(height: 16),

                    // ── Submit ────────────────────────────────────────────────────
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                          shadowColor: color.withValues(alpha: 0.3),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
