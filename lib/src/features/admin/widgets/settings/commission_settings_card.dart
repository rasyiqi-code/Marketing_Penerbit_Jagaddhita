import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

/// Kartu pengaturan komisi untuk Penerbitan (R1).
/// Mendukung komisi flat (per kategori: Reseller, Distributor) dan toggle aktif/nonaktif.
class CommissionSettingsCard extends StatelessWidget {
  final bool enableR1Commission;
  final TextEditingController bonusR1Controller;
  final TextEditingController resellerCommissionController;
  final TextEditingController distributorCommissionController;
  final ValueChanged<bool> onR1CommissionChanged;

  const CommissionSettingsCard({
    super.key,
    required this.enableR1Commission,
    required this.bonusR1Controller,
    required this.resellerCommissionController,
    required this.distributorCommissionController,
    required this.onR1CommissionChanged,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Aktifkan Komisi Tunai (Penerbitan)'),
            value: enableR1Commission,
            onChanged: onR1CommissionChanged,
          ),
          if (enableR1Commission) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                controller: bonusR1Controller,
                keyboardType: TextInputType.number,
                label: 'Persentase Komisi Penulis (%)',
                icon: Icons.percent,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                controller: resellerCommissionController,
                keyboardType: TextInputType.number,
                label: 'Persentase Komisi Reseller (%)',
                icon: Icons.percent,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                controller: distributorCommissionController,
                keyboardType: TextInputType.number,
                label: 'Persentase Komisi Distributor (%)',
                icon: Icons.percent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
