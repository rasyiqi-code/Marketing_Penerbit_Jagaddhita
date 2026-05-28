import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

/// Mengontrol tampilan & menu utama di dashboard marketing, serta
/// konfigurasi identitas penerbit untuk faktur penjualan.
class AppearanceSettingsCard extends StatelessWidget {
  final bool enableR1;
  final ValueChanged<bool> onR1Changed;
  final TextEditingController publisherNameController;
  final TextEditingController publisherSloganController;
  final TextEditingController bankNameController;
  final TextEditingController bankAccountNoController;
  final TextEditingController bankAccountNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController contactEmailController;

  const AppearanceSettingsCard({
    super.key,
    required this.enableR1,
    required this.onR1Changed,
    required this.publisherNameController,
    required this.publisherSloganController,
    required this.bankNameController,
    required this.bankAccountNoController,
    required this.bankAccountNameController,
    required this.contactPhoneController,
    required this.contactEmailController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Menu Input Penjualan Buku'),
            subtitle: const Text('Tampilkan menu input penjualan di Dashboard'),
            value: enableR1,
            onChanged: onR1Changed,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 24),
          Text(
            'Identitas Faktur / Invoice',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: publisherNameController,
            label: 'Nama Penerbit Faktur',
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: publisherSloganController,
            label: 'Slogan / Subtitle Faktur',
            icon: Icons.short_text_rounded,
          ),
          const Divider(height: 24),
          Text(
            'Metode Pembayaran Faktur (Transfer Bank)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: AppTextField(
                  controller: bankNameController,
                  label: 'Nama Bank (e.g. BCA)',
                  icon: Icons.account_balance_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: AppTextField(
                  controller: bankAccountNoController,
                  label: 'No Rekening',
                  icon: Icons.credit_card_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: bankAccountNameController,
            label: 'Nama Pemilik Rekening (A/N)',
            icon: Icons.person_rounded,
          ),
          const Divider(height: 24),
          Text(
            'Informasi Kontak Penerbit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: contactPhoneController,
            label: 'Nomor WA Kontak (Faktur)',
            icon: Icons.phone_rounded,
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: contactEmailController,
            label: 'Email Kontak (Faktur)',
            icon: Icons.email_rounded,
          ),
        ],
      ),
    );
  }
}
