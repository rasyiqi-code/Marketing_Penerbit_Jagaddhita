import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';

/// Kartu pengaturan komisi untuk Penjualan Buku (R1) dan Sistem Tier Hibrida.
class CommissionSettingsCard extends StatelessWidget {
  final bool enableR1Commission;
  final TextEditingController bonusR1Controller;
  final String discountCalculationMethod;
  final ValueChanged<String?> onMethodChanged;
  
  final TextEditingController goldCommissionJagaddhitaController;
  final TextEditingController platinumCommissionJagaddhitaController;
  final TextEditingController premiumCommissionJagaddhitaController;
  
  final TextEditingController goldCommissionSibiController;
  final TextEditingController platinumCommissionSibiController;
  final TextEditingController premiumCommissionSibiController;
  
  final TextEditingController goldThresholdController;
  final TextEditingController platinumThresholdController;
  final TextEditingController premiumThresholdController;
  
  final ValueChanged<bool> onR1CommissionChanged;

  const CommissionSettingsCard({
    super.key,
    required this.enableR1Commission,
    required this.bonusR1Controller,
    required this.discountCalculationMethod,
    required this.onMethodChanged,
    required this.goldCommissionJagaddhitaController,
    required this.platinumCommissionJagaddhitaController,
    required this.premiumCommissionJagaddhitaController,
    required this.goldCommissionSibiController,
    required this.platinumCommissionSibiController,
    required this.premiumCommissionSibiController,
    required this.goldThresholdController,
    required this.platinumThresholdController,
    required this.premiumThresholdController,
    required this.onR1CommissionChanged,
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
            title: const Text('Aktifkan Komisi Tunai (Penjualan Buku)'),
            value: enableR1Commission,
            onChanged: onR1CommissionChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (enableR1Commission) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppTextField(
                controller: bonusR1Controller,
                keyboardType: TextInputType.number,
                label: 'Persentase Komisi Reguler (%)',
                icon: Icons.percent,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: DropdownButtonFormField<String>(
                initialValue: discountCalculationMethod,
                decoration: const InputDecoration(
                  labelText: 'Metode Perhitungan Tier',
                  prefixIcon: Icon(Icons.calculate_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual Pangkat Permanen')),
                  DropdownMenuItem(value: 'per_transaction', child: Text('Otomatis Per Transaksi')),
                  DropdownMenuItem(value: 'cumulative_monthly', child: Text('Otomatis Akumulasi Bulanan')),
                ],
                onChanged: onMethodChanged,
              ),
            ),
            const SizedBox(height: 10),
            
            // Gold
            _buildTierConfig(
              title: 'Pengaturan Reseller GOLD',
              commissionJagaddhitaCtrl: goldCommissionJagaddhitaController,
              commissionSibiCtrl: goldCommissionSibiController,
              thresholdCtrl: goldThresholdController,
              showThreshold: discountCalculationMethod != 'manual',
              color: Colors.amber.shade700,
            ),
            
            // Platinum
            _buildTierConfig(
              title: 'Pengaturan Reseller PLATINUM',
              commissionJagaddhitaCtrl: platinumCommissionJagaddhitaController,
              commissionSibiCtrl: platinumCommissionSibiController,
              thresholdCtrl: platinumThresholdController,
              showThreshold: discountCalculationMethod != 'manual',
              color: Colors.blueGrey.shade600,
            ),
            
            // Premium
            _buildTierConfig(
              title: 'Pengaturan Reseller PREMIUM',
              commissionJagaddhitaCtrl: premiumCommissionJagaddhitaController,
              commissionSibiCtrl: premiumCommissionSibiController,
              thresholdCtrl: premiumThresholdController,
              showThreshold: discountCalculationMethod != 'manual',
              color: Colors.grey.shade900,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTierConfig({
    required String title,
    required TextEditingController commissionJagaddhitaCtrl,
    required TextEditingController commissionSibiCtrl,
    required TextEditingController thresholdCtrl,
    required bool showThreshold,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: commissionJagaddhitaCtrl,
                  keyboardType: TextInputType.number,
                  label: 'JGD (%)',
                  icon: Icons.auto_graph_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: commissionSibiCtrl,
                  keyboardType: TextInputType.number,
                  label: 'SIBI (%)',
                  icon: Icons.school_rounded,
                ),
              ),
            ],
          ),
          if (showThreshold) ...[
            const SizedBox(height: 8),
            AppTextField(
              controller: thresholdCtrl,
              keyboardType: TextInputType.number,
              label: 'Batas Bawah (Rp)',
              icon: Icons.attach_money,
            ),
          ],
        ],
      ),
    );
  }
}
