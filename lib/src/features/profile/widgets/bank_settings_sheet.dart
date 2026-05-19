import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

/// Bottom sheet untuk mengubah detail bank/rekening marketing.
Future<void> showBankSettingsSheet({
  required BuildContext context,
  required UserModel user,
  required TextEditingController bankNameController,
  required TextEditingController accNumberController,
  required TextEditingController holderNameController,
  required TextEditingController phoneController,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _BankSettingsSheet(
      user: user,
      bankNameController: bankNameController,
      accNumberController: accNumberController,
      holderNameController: holderNameController,
      phoneController: phoneController,
      onSaved: onSaved,
    ),
  );
}

class _BankSettingsSheet extends StatelessWidget {
  final UserModel user;
  final TextEditingController bankNameController;
  final TextEditingController accNumberController;
  final TextEditingController holderNameController;
  final TextEditingController phoneController;
  final VoidCallback onSaved;

  const _BankSettingsSheet({
    required this.user,
    required this.bankNameController,
    required this.accNumberController,
    required this.holderNameController,
    required this.phoneController,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informasi Bank',
            style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: bankNameController,
            label: 'Nama Bank',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: accNumberController,
            label: 'Nomor Rekening',
            icon: Icons.numbers_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: holderNameController,
            label: 'Nama Pemilik Rekening',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: phoneController,
            label: 'No. HP / E-Wallet',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _save(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan Detail'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final bankName = bankNameController.text.trim();
    final accNumber = accNumberController.text.trim();
    final holderName = holderNameController.text.trim();

    if (bankName.isEmpty || accNumber.isEmpty || holderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama bank, nomor rekening, dan nama pemilik wajib diisi')),
      );
      return;
    }

    if (accNumber.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor rekening minimal 8 digit')),
      );
      return;
    }

    try {
      await Provider.of<UserService>(context, listen: false).updateUserBankDetails(
        user.id,
        {
          'bank_name': bankName,
          'account_number': accNumber,
          'account_holder': holderName,
          'phone': phoneController.text.trim(),
        },
      );

      if (context.mounted) {
        Navigator.pop(context);
        onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail bank berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
