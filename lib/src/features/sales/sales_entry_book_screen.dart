import 'package:flutter/material.dart';
import 'dart:async';
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
import 'package:marketing_penerbit_jagaddhita/src/features/sales/utils/sales_calculator_helper.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/product_picker_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/markup_input_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/transaction_proof_input.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/sales/widgets/sales_entry_shared_widgets.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'widgets/sales_entry/sales_review_dialog.dart';
import 'widgets/sales_entry/customer_suggestions_list.dart';
import 'widgets/sales_entry/sales_disabled_banner.dart';
import 'widgets/sales_entry/selected_products_stepper_list.dart';

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
  final _customerAddressController = TextEditingController();
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _showCustomerSuggestions = false;

  // Controllers
  final _markupController = TextEditingController();
  final _dpAmountController = TextEditingController();

  String _paymentStatus = 'DP';
  Timer? _debounceTimer;

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
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
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
    });
  }

  void _calculateValues() {
    final result = SalesCalculatorHelper.calculate(
      selectedProducts: _selectedProducts,
      selectedProductQuantities: _selectedProductQuantities,
      settings: _settings,
      marketingCategory: _marketingCategory,
      monthlySalesTotal: _monthlySalesTotal,
      monthlySalesCount: _monthlySalesCount,
      userMonthlyBonusCount: _userMonthlyBonusCount,
    );

    _bruto = result.bruto;
    _discountPercent = result.discountPercent;
    _discountAmount = result.discountAmount;
    _netto = result.netto;
    _commissionAmount = result.commissionAmount;
    _pulsaBonusAmount = result.pulsaBonusAmount;

    if (mounted) setState(() {});
  }

  Future<void> _submitSale() async {
    FocusScope.of(context).unfocus();

    final auth = Provider.of<AuthService>(context, listen: false);
    final salesService = Provider.of<SalesService>(context, listen: false);
    final customerService = Provider.of<CustomerService>(context, listen: false);
    final notificationService = Provider.of<FirestoreNotificationService>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih produk terlebih dahulu')),
      );
      return;
    }

    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();
    final customerAddress = _customerAddressController.text.trim();

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
    if (customerAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan alamat lengkap customer')),
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

    // Validasi bukti transfer sebelum submit
    if (_paymentStatus != 'COD' && _transactionProofUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah bukti transfer terlebih dahulu')),
      );
      return;
    }

    // Tampilkan dialog review pesanan sebelum mengirimkan data
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => SalesReviewDialog(
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        selectedProducts: _selectedProducts,
        selectedProductQuantities: _selectedProductQuantities,
        paymentStatus: _paymentStatus,
        bruto: _bruto,
        commissionAmount: _commissionAmount,
        netto: _netto,
        dpAmountText: _dpAmountController.text,
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
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
          'customer_address': customerAddress,
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
    _debounceTimer?.cancel();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _markupController.dispose();
    _dpAmountController.dispose();
    super.dispose();
  }

  bool get _isFormDirty {
    return _customerNameController.text.isNotEmpty ||
        _customerPhoneController.text.isNotEmpty ||
        _customerAddressController.text.isNotEmpty ||
        _selectedProducts.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.primaryColor;
    final totalQty = _selectedProductQuantities.values.fold<int>(0, (sum, q) => sum + q);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_isFormDirty) {
          if (context.mounted) Navigator.of(context).pop(result);
          return;
        }
        final shouldPop = await AppDialogs.showConfirmDialog(
          context: context,
          title: 'Batal Menginput?',
          content: 'Apakah Anda yakin ingin keluar? Semua data form yang telah diisi akan hilang.',
          confirmLabel: 'Ya, Keluar',
          cancelLabel: 'Batal',
          isDanger: true,
        );
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
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
        body: _settings == null
            ? const Center(child: CircularProgressIndicator())
            : !_settings!.enableR1
                ? const SalesDisabledBanner()
                : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: AbsorbPointer(
                  absorbing: _isLoading,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _customerNameController,
                          label: 'Nama Customer',
                          icon: Icons.person_outline_rounded,
                          onChanged: _onCustomerNameChanged,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi ya' : null,
                        ),
                        if (_showCustomerSuggestions) ...[
                          const SizedBox(height: 4),
                          CustomerSuggestionsList(
                            customers: _filteredCustomers,
                            onSelected: (customer) {
                              setState(() {
                                _customerNameController.text = customer.name;
                                _customerPhoneController.text = customer.phoneNumber;
                                _showCustomerSuggestions = false;
                                _filteredCustomers = [];
                              });
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ],
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _customerPhoneController,
                          label: 'Nomor HP Customer',
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi ya' : null,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _customerAddressController,
                          label: 'Alamat Lengkap (Jl, RT/RW, Kec, Kota)',
                          icon: Icons.location_on_outlined,
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi ya' : null,
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
                      SelectedProductsStepperList(
                        selectedProducts: _selectedProducts,
                        selectedProductQuantities: _selectedProductQuantities,
                        onQuantityChanged: (product, qty) {
                          setState(() {
                            _selectedProductQuantities[product.id] = qty;
                            _calculateValues();
                          });
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
                      AppTextField(
                        controller: _dpAmountController,
                        label: 'Jumlah DP yang Dibayar',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        prefixText: 'Rp ',
                        inputFormatters: [CurrencyInputFormatter()],
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi ya' : null,
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
                        onPressed: _isLoading ? null : _submitSale,
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Mengirim Transaksi...',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
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
