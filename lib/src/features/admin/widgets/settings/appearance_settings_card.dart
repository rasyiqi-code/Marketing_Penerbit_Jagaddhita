import 'package:flutter/material.dart';

/// Mengontrol visibilitas menu utama di dashboard marketing.
/// Saat ini hanya ada satu menu (Penerbitan), R2/Creator telah dihapus.
class AppearanceSettingsCard extends StatelessWidget {
  final bool enableR1;
  final ValueChanged<bool> onR1Changed;

  const AppearanceSettingsCard({
    super.key,
    required this.enableR1,
    required this.onR1Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: const Text('Menu Input Penerbitan'),
        subtitle: const Text('Tampilkan menu input penjualan di Dashboard'),
        value: enableR1,
        onChanged: onR1Changed,
      ),
    );
  }
}
