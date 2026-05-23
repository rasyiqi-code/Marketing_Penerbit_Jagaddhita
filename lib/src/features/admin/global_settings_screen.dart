import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/data_seeder_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/announcement_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/appearance_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/bonus_pulsa_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/commission_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/danger_zone_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/withdrawal_settings_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/settings/settings_scaffold_widgets.dart';
import 'package:provider/provider.dart';

class GlobalSettingsScreen extends StatefulWidget {
  const GlobalSettingsScreen({super.key});

  @override
  State<GlobalSettingsScreen> createState() => _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends State<GlobalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bonusR1Controller;
  late TextEditingController _goldCommissionJagaddhitaController;
  late TextEditingController _platinumCommissionJagaddhitaController;
  late TextEditingController _premiumCommissionJagaddhitaController;
  late TextEditingController _goldCommissionSibiController;
  late TextEditingController _platinumCommissionSibiController;
  late TextEditingController _premiumCommissionSibiController;
  late TextEditingController _goldThresholdController;
  late TextEditingController _platinumThresholdController;
  late TextEditingController _premiumThresholdController;
  String _discountCalculationMethod = 'manual';
  late TextEditingController _pulsaBonusController;
  late TextEditingController _minSalePulsaController;
  late TextEditingController _minPayoutController;
  late TextEditingController _minPulsaWithdrawalController;
  late TextEditingController _latestInfoController;
  late TextEditingController _webBaseUrlController;
  late TextEditingController _maxPulsaBonusCountController;
  late TextEditingController _minCompletedSalesCountController;

  // Progressive settings removed

  bool _enableR1 = true;
  bool _enableR1Commission = true;
  bool _enableR1PulsaBonus = true;
  bool _enableMaxPulsaBonusLimit = false;
  bool _enableMinCompletedSalesLimit = false;
  bool _enableMinSalesLimit = true;

  List<int> _allowedWithdrawalDays = [1, 2, 3, 4, 5, 6, 7];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bonusR1Controller = TextEditingController();
    _goldCommissionJagaddhitaController = TextEditingController();
    _platinumCommissionJagaddhitaController = TextEditingController();
    _premiumCommissionJagaddhitaController = TextEditingController();
    _goldCommissionSibiController = TextEditingController();
    _platinumCommissionSibiController = TextEditingController();
    _premiumCommissionSibiController = TextEditingController();
    _goldThresholdController = TextEditingController();
    _platinumThresholdController = TextEditingController();
    _premiumThresholdController = TextEditingController();
    _pulsaBonusController = TextEditingController();
    _minSalePulsaController = TextEditingController();
    _minPayoutController = TextEditingController();
    _minPulsaWithdrawalController = TextEditingController();
    _latestInfoController = TextEditingController();
    _webBaseUrlController = TextEditingController();
    _maxPulsaBonusCountController = TextEditingController();
    _minCompletedSalesCountController = TextEditingController();
    // Progressive controllers removed
    _loadSettings();
  }

  void _loadSettings() {
    final productService = Provider.of<ProductService>(context, listen: false);
    productService.getGlobalSettings().first.then((settings) {
      if (mounted) {
        setState(() {
          _bonusR1Controller.text = settings.bonusPercentR1.toString();
          _discountCalculationMethod = settings.discountCalculationMethod;
          _goldCommissionJagaddhitaController.text = settings.goldCommissionPercentJagaddhita.toString();
          _platinumCommissionJagaddhitaController.text = settings.platinumCommissionPercentJagaddhita.toString();
          _premiumCommissionJagaddhitaController.text = settings.premiumCommissionPercentJagaddhita.toString();
          _goldCommissionSibiController.text = settings.goldCommissionPercentSibi.toString();
          _platinumCommissionSibiController.text = settings.platinumCommissionPercentSibi.toString();
          _premiumCommissionSibiController.text = settings.premiumCommissionPercentSibi.toString();
          _goldThresholdController.text = settings.goldThreshold.toStringAsFixed(0);
          _platinumThresholdController.text = settings.platinumThreshold.toStringAsFixed(0);
          _premiumThresholdController.text = settings.premiumThreshold.toStringAsFixed(0);
          _pulsaBonusController.text =
              settings.pulsaBonusAmount.toStringAsFixed(0);
          _minSalePulsaController.text =
              settings.minSaleForPulsa.toStringAsFixed(0);
          _minPayoutController.text = settings.minPayout.toStringAsFixed(0);
          _minPulsaWithdrawalController.text =
              settings.minPulsaWithdrawal.toStringAsFixed(0);
          _latestInfoController.text = settings.latestInfo;
          _webBaseUrlController.text = settings.webBaseUrl;

          _enableR1 = settings.enableR1;
          _enableR1Commission = settings.enableR1Commission;
          _enableR1PulsaBonus = settings.enableR1PulsaBonus;
          _allowedWithdrawalDays = List.from(settings.allowedWithdrawalDays);

          _enableMaxPulsaBonusLimit = settings.enableMaxPulsaBonusLimit;
          _maxPulsaBonusCountController.text =
              settings.maxPulsaBonusCount.toString();
          _enableMinCompletedSalesLimit = settings.enableMinCompletedSalesLimit;
          _minCompletedSalesCountController.text =
              settings.minCompletedSalesCount.toString();
          _enableMinSalesLimit = settings.enableMinSalesLimit;

          // Progressive fields removed
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final productService =
          Provider.of<ProductService>(context, listen: false);
      final settings = GlobalSettingsModel(
        bonusPercentR1: double.tryParse(_bonusR1Controller.text) ?? 0,
        discountCalculationMethod: _discountCalculationMethod,
        goldCommissionPercentJagaddhita: double.tryParse(_goldCommissionJagaddhitaController.text) ?? 30.0,
        platinumCommissionPercentJagaddhita: double.tryParse(_platinumCommissionJagaddhitaController.text) ?? 40.0,
        premiumCommissionPercentJagaddhita: double.tryParse(_premiumCommissionJagaddhitaController.text) ?? 50.0,
        goldCommissionPercentSibi: double.tryParse(_goldCommissionSibiController.text) ?? 25.0,
        platinumCommissionPercentSibi: double.tryParse(_platinumCommissionSibiController.text) ?? 35.0,
        premiumCommissionPercentSibi: double.tryParse(_premiumCommissionSibiController.text) ?? 45.0,
        goldThreshold: double.tryParse(_goldThresholdController.text) ?? 100000.0,
        platinumThreshold: double.tryParse(_platinumThresholdController.text) ?? 3000000.0,
        premiumThreshold: double.tryParse(_premiumThresholdController.text) ?? 25000000.0,
        pulsaBonusAmount:
            double.tryParse(_pulsaBonusController.text) ?? 50000,
        minSaleForPulsa:
            double.tryParse(_minSalePulsaController.text) ?? 10000000,
        minPayout: double.tryParse(_minPayoutController.text) ?? 0,
        minPulsaWithdrawal:
            double.tryParse(_minPulsaWithdrawalController.text) ?? 20000,
        // Progressive fields removed
        enableR1: _enableR1,
        enableR1Commission: _enableR1Commission,
        enableR1PulsaBonus: _enableR1PulsaBonus,
        allowedWithdrawalDays: _allowedWithdrawalDays,
        latestInfo: _latestInfoController.text,
        webBaseUrl: _webBaseUrlController.text,
        enableMaxPulsaBonusLimit: _enableMaxPulsaBonusLimit,
        maxPulsaBonusCount:
            int.tryParse(_maxPulsaBonusCountController.text) ?? 1,
        enableMinCompletedSalesLimit: _enableMinCompletedSalesLimit,
        minCompletedSalesCount:
            int.tryParse(_minCompletedSalesCountController.text) ?? 5,
        enableMinSalesLimit: _enableMinSalesLimit,
      );
      await productService.updateGlobalSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seedData() async {
    setState(() => _isLoading = true);
    try {
      await DataSeederService().seedDemoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data demo berhasil ditambahkan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error seeding: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'PERINGATAN: Tindakan ini akan MENGHAPUS SEMUA data (Produk, Penjualan, Riwayat Saldo, Notifikasi, dan Reset Saldo Pengguna) secara permanen.\n\nData yang dihapus TIDAK BISA dipulihkan. Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semuanya'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await DataSeederService().clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data berhasil dihapus!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _bonusR1Controller.dispose();
    _goldCommissionJagaddhitaController.dispose();
    _platinumCommissionJagaddhitaController.dispose();
    _premiumCommissionJagaddhitaController.dispose();
    _goldCommissionSibiController.dispose();
    _platinumCommissionSibiController.dispose();
    _premiumCommissionSibiController.dispose();
    _goldThresholdController.dispose();
    _platinumThresholdController.dispose();
    _premiumThresholdController.dispose();
    _pulsaBonusController.dispose();
    _minSalePulsaController.dispose();
    _minPayoutController.dispose();
    _minPulsaWithdrawalController.dispose();
    _latestInfoController.dispose();
    _webBaseUrlController.dispose();
    _maxPulsaBonusCountController.dispose();
    _minCompletedSalesCountController.dispose();
    // Progressive fields removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan Global'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SettingsSectionHeader(
                  title: 'Tampilan & Menu',
                  icon: Icons.dashboard_customize_rounded,
                ),
                AppearanceSettingsCard(
                  enableR1: _enableR1,
                  onR1Changed: (val) => setState(() => _enableR1 = val),
                ),
                const SizedBox(height: 12),
                const SettingsSectionHeader(
                  title: 'Pengumuman & Link',
                  icon: Icons.campaign_rounded,
                ),
                AnnouncementSettingsCard(
                  latestInfoController: _latestInfoController,
                  webBaseUrlController: _webBaseUrlController,
                ),
                const SizedBox(height: 12),
                const SettingsSectionHeader(
                  title: 'Komisi Penjualan (Tunai)',
                  icon: Icons.monetization_on_rounded,
                ),
                CommissionSettingsCard(
                  enableR1Commission: _enableR1Commission,
                  bonusR1Controller: _bonusR1Controller,
                  discountCalculationMethod: _discountCalculationMethod,
                  onMethodChanged: (val) {
                    if (val != null) setState(() => _discountCalculationMethod = val);
                  },
                  goldCommissionJagaddhitaController: _goldCommissionJagaddhitaController,
                  platinumCommissionJagaddhitaController: _platinumCommissionJagaddhitaController,
                  premiumCommissionJagaddhitaController: _premiumCommissionJagaddhitaController,
                  goldCommissionSibiController: _goldCommissionSibiController,
                  platinumCommissionSibiController: _platinumCommissionSibiController,
                  premiumCommissionSibiController: _premiumCommissionSibiController,
                  goldThresholdController: _goldThresholdController,
                  platinumThresholdController: _platinumThresholdController,
                  premiumThresholdController: _premiumThresholdController,
                  onR1CommissionChanged: (val) =>
                      setState(() => _enableR1Commission = val),
                ),
                // Progressive card removed
                const SizedBox(height: 12),
                const SettingsSectionHeader(
                  title: 'Pengaturan Bonus Pulsa',
                  icon: Icons.phonelink_ring_rounded,
                ),
                BonusPulsaSettingsCard(
                  enableR1PulsaBonus: _enableR1PulsaBonus,
                  pulsaBonusController: _pulsaBonusController,
                  onR1PulsaBonusChanged: (val) =>
                      setState(() => _enableR1PulsaBonus = val),
                  enableMinSalesLimit: _enableMinSalesLimit,
                  minSalePulsaController: _minSalePulsaController,
                  onMinSalesLimitChanged: (val) =>
                      setState(() => _enableMinSalesLimit = val),
                  enableMaxPulsaBonusLimit: _enableMaxPulsaBonusLimit,
                  maxPulsaBonusCountController: _maxPulsaBonusCountController,
                  onMaxPulsaBonusLimitChanged: (val) =>
                      setState(() => _enableMaxPulsaBonusLimit = val),
                  enableMinCompletedSalesLimit: _enableMinCompletedSalesLimit,
                  minCompletedSalesCountController:
                      _minCompletedSalesCountController,
                  onMinCompletedSalesLimitChanged: (val) =>
                      setState(() => _enableMinCompletedSalesLimit = val),
                ),
                const SizedBox(height: 12),
                const SettingsSectionHeader(
                  title: 'Penarikan Dana (Withdrawal)',
                  icon: Icons.account_balance_wallet_rounded,
                ),
                WithdrawalSettingsCard(
                  minPayoutController: _minPayoutController,
                  minPulsaWithdrawalController: _minPulsaWithdrawalController,
                  allowedWithdrawalDays: _allowedWithdrawalDays,
                  onDayToggle: (day) {
                    setState(() {
                      if (_allowedWithdrawalDays.contains(day)) {
                        _allowedWithdrawalDays.remove(day);
                      } else {
                        _allowedWithdrawalDays.add(day);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                SettingsSaveButton(
                  isLoading: _isLoading,
                  onPressed: _saveSettings,
                ),
                const SizedBox(height: 24),
                const SettingsSectionHeader(
                  title: 'Area Berbahaya',
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                ),
                DangerZoneSettingsCard(
                  isLoading: _isLoading,
                  onSeedData: _seedData,
                  onResetData: _resetData,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
