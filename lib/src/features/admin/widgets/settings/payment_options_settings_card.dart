import 'package:flutter/material.dart';

class PaymentOptionsSettingsCard extends StatelessWidget {
  final bool enablePaymentDP;
  final ValueChanged<bool> onDPChanged;
  final bool enablePaymentCOD;
  final ValueChanged<bool> onCODChanged;

  const PaymentOptionsSettingsCard({
    super.key,
    required this.enablePaymentDP,
    required this.onDPChanged,
    required this.enablePaymentCOD,
    required this.onCODChanged,
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
            title: const Text('Aktifkan Pembayaran DP'),
            subtitle: const Text('Tampilkan opsi DP (Down Payment) pada form penjualan.'),
            value: enablePaymentDP,
            onChanged: onDPChanged,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
          const Divider(height: 16),
          SwitchListTile(
            title: const Text('Aktifkan Pembayaran COD'),
            subtitle: const Text('Tampilkan opsi COD (Cash on Delivery) pada form penjualan.'),
            value: enablePaymentCOD,
            onChanged: onCODChanged,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
