import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/wallet/widgets/withdrawal_widgets.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  final UserModel user;
  final String allowedType;

  const WithdrawalRequestScreen({
    super.key,
    required this.user,
    required this.allowedType,
  });

  @override
  State<WithdrawalRequestScreen> createState() =>
      _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  late TextEditingController _amountController;
  late TextEditingController _infoController;
  bool _isLoading = false;

  bool get isBank =>
      widget.allowedType == ClaimModel.typeBank ||
      widget.allowedType == 'markup';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _infoController = TextEditingController(text: _getAutoFillText(widget.user));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  String _getAutoFillText(UserModel user) {
    if (user.bankDetails == null || user.bankDetails!.isEmpty) return '';

    if (isBank) {
      final bankName = user.bankDetails!['bank_name'] ?? '';
      final accNum = user.bankDetails!['account_number'] ?? '';
      final holder = user.bankDetails!['account_holder'] ?? '';

      if (bankName.isNotEmpty && accNum.isNotEmpty) {
        return '$bankName $accNum a.n $holder'.trim();
      }
      if (bankName.isNotEmpty) return bankName;
      if (accNum.isNotEmpty) return accNum;
      return '';
    } else {
      return user.bankDetails!['phone'] ?? '';
    }
  }

  Future<void> _submitRequest(GlobalSettingsModel settings) async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    final notificationService = Provider.of<FirestoreNotificationService>(context, listen: false);

    final amount = int.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nominal tidak valid')));
      return;
    }

    final minAmount = isBank ? settings.minPayout : settings.minPulsaWithdrawal;

    if (amount < minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal penarikan adalah ${AppFormatters.currency(minAmount)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_infoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBank ? 'Isi data bank' : 'Isi nomor HP')),
      );
      return;
    }

    int currentBalance = 0;
    if (widget.allowedType == ClaimModel.typeBank) {
      currentBalance =
          widget.user.commissionBalance + widget.user.markupBalance;
    } else if (widget.allowedType == 'markup') {
      currentBalance = widget.user.markupBalance;
    } else {
      currentBalance = widget.user.pulsaBalance;
    }
    if (amount > currentBalance) {
      AppDialogs.showErrorSnackBar(context, 'Saldo tidak mencukupi');
      return;
    }

    final typeName = isBank ? 'Transfer Bank' : 'Klaim Pulsa';
    final targetInfo = _infoController.text.trim();

    final confirm = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Konfirmasi Penarikan',
      content: 'Apakah Anda yakin ingin mengajukan penarikan berikut?\n\n'
          '• Tipe Penarikan: $typeName\n'
          '• Nominal: ${AppFormatters.currency(amount)}\n'
          '• ${isBank ? "Rekening Tujuan" : "Nomor HP Tujuan"}: $targetInfo',
      confirmLabel: 'Konfirmasi',
      cancelLabel: 'Batal',
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final claim = ClaimModel(
      id: '',
      userId: widget.user.id,
      amount: amount,
      type: widget.allowedType,
      status: ClaimModel.statusPending,
      bankDetails: {'info': targetInfo},
      createdAt: DateTime.now(),
    );

    try {
      final claimId = await walletService.requestClaim(claim);

      final notification = NotificationModel(
        id: '',
        title: isBank ? 'Permintaan Withdraw Baru' : 'Permintaan Pulsa Baru',
        body:
            '${widget.user.name ?? "User"} meminta ${isBank ? "withdraw (${widget.allowedType})" : "pulsa"} sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(amount)}',
        type: NotificationModel.typeInfo,
        recipientId: 'role:admin',
        relatedId: claimId,
        createdAt: DateTime.now(),
      );
      await notificationService.sendNotification(notification);

      if (mounted) {
        AppDialogs.showSuccessSnackBar(context, 'Permintaan terkirim!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, 'Gagal: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isBank ? 'Tarik Saldo Komisi' : 'Klaim Saldo Pulsa';
    final userService = Provider.of<UserService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<UserModel>(
        stream: userService.getUserStream(widget.user.id),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = userSnapshot.data!;
          final autoFillText = _getAutoFillText(currentUser);
          if (_infoController.text != autoFillText) {
            _infoController.text = autoFillText;
          }
          final availableBalance = isBank
              ? (currentUser.commissionBalance + currentUser.markupBalance)
              : currentUser.pulsaBalance;

          return StreamBuilder<GlobalSettingsModel>(
            stream: productService.getGlobalSettings(),
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasError) {
                return Center(child: Text('Error: ${settingsSnapshot.error}'));
              }
              if (!settingsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final settings = settingsSnapshot.data!;
              final today = DateTime.now().weekday;
              final isAllowedDay = settings.allowedWithdrawalDays.contains(today);
              final dayName =
                  [
                    'Senin',
                    'Selasa',
                    'Rabu',
                    'Kamis',
                    'Jumat',
                    'Sabtu',
                    'Minggu',
                  ][today - 1];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WithdrawalAllowedDayWarning(
                      isAllowedDay: isAllowedDay,
                      dayName: dayName,
                    ),

                    WithdrawalBalanceCard(
                      isBank: isBank,
                      balance: availableBalance,
                    ),
                    const SizedBox(height: 10),

                    WithdrawalForm(
                      isBank: isBank,
                      isAllowedDay: isAllowedDay,
                      isLoading: _isLoading,
                      minWithdrawalAmount: isBank ? settings.minPayout : settings.minPulsaWithdrawal,
                      availableBalance: availableBalance,
                      amountController: _amountController,
                      infoController: _infoController,
                      onTarikSemua: () {
                        setState(() {
                          _amountController.text = availableBalance.toStringAsFixed(0);
                        });
                      },
                      onSubmit: () => _submitRequest(settings),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
