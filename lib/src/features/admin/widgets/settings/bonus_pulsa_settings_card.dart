import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

/// Kartu pengaturan bonus pulsa untuk Penjualan Buku.
/// Mengatur nominal bonus, aturan target penjualan, dan batasan frekuensi bulanan.
class BonusPulsaSettingsCard extends StatelessWidget {
  final bool enableR1PulsaBonus;
  final TextEditingController pulsaBonusController;
  final ValueChanged<bool> onR1PulsaBonusChanged;

  final bool enableMinSalesLimit;
  final TextEditingController minSalePulsaController;
  final ValueChanged<bool> onMinSalesLimitChanged;

  final bool enableMaxPulsaBonusLimit;
  final TextEditingController maxPulsaBonusCountController;
  final ValueChanged<bool> onMaxPulsaBonusLimitChanged;

  final bool enableMinCompletedSalesLimit;
  final TextEditingController minCompletedSalesCountController;
  final ValueChanged<bool> onMinCompletedSalesLimitChanged;

  const BonusPulsaSettingsCard({
    super.key,
    required this.enableR1PulsaBonus,
    required this.pulsaBonusController,
    required this.onR1PulsaBonusChanged,
    required this.enableMinSalesLimit,
    required this.minSalePulsaController,
    required this.onMinSalesLimitChanged,
    required this.enableMaxPulsaBonusLimit,
    required this.maxPulsaBonusCountController,
    required this.onMaxPulsaBonusLimitChanged,
    required this.enableMinCompletedSalesLimit,
    required this.minCompletedSalesCountController,
    required this.onMinCompletedSalesLimitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bonus Pulsa Penjualan Buku
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonus Pulsa Penjualan Buku',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Aktifkan Bonus Pulsa'),
                  value: enableR1PulsaBonus,
                  onChanged: onR1PulsaBonusChanged,
                  contentPadding: EdgeInsets.zero,
                ),
                AppTextField(
                  controller: pulsaBonusController,
                  keyboardType: TextInputType.number,
                  label: 'Nominal Bonus',
                  icon: Icons.money,
                  prefixText: 'Rp ',
                  fillColor: Theme.of(context).cardColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Global Rules
          const Row(
            children: [
              Icon(Icons.gavel_rounded, size: 18, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                'Aturan & Batasan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            title: const Text('Wajib Mencapai Target Penjualan'),
            subtitle: const Text(
              'Bonus cair jika TOTAL penjualan bulan ini mencapai target',
            ),
            value: enableMinSalesLimit,
            onChanged: onMinSalesLimitChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (enableMinSalesLimit)
            AppTextField(
              controller: minSalePulsaController,
              keyboardType: TextInputType.number,
              label: 'Target Akumulasi Penjualan (Bulanan)',
              icon: Icons.track_changes,
              prefixText: 'Rp ',
              helperText: 'Min. total penjualan sebulan agar bonus cair',
            ),
          const Divider(height: 16),
          SwitchListTile(
            title: const Text('Batasi Frekuensi Bulanan'),
            subtitle: const Text('Maksimal kali dapat bonus per bulan'),
            value: enableMaxPulsaBonusLimit,
            onChanged: onMaxPulsaBonusLimitChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (enableMaxPulsaBonusLimit)
            AppTextField(
              controller: maxPulsaBonusCountController,
              keyboardType: TextInputType.number,
              label: 'Maksimal (Kali)',
              icon: Icons.repeat_one_rounded,
              helperText: 'Contoh: 1x sebulan',
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Syarat Riwayat Penjualan'),
            subtitle: const Text('Minimal total transaksi sukses bulan ini'),
            value: enableMinCompletedSalesLimit,
            onChanged: onMinCompletedSalesLimitChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (enableMinCompletedSalesLimit)
            AppTextField(
              controller: minCompletedSalesCountController,
              keyboardType: TextInputType.number,
              label: 'Min. Akumulasi Transaksi (Bulanan)',
              icon: Icons.history_edu_rounded,
              helperText: 'Alternatif jika target nominal tidak tercapai',
            ),
        ],
      ),
    );
  }
}
