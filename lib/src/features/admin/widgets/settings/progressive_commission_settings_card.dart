import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

class ProgressiveCommissionSettingsCard extends StatefulWidget {
  final TextEditingController thresholdJagaddhitaMediumController;
  final TextEditingController percentJagaddhitaMediumController;
  final TextEditingController thresholdJagaddhitaHighController;
  final TextEditingController percentJagaddhitaHighController;
  final TextEditingController thresholdSibiController;
  final TextEditingController percentSibiController;

  const ProgressiveCommissionSettingsCard({
    super.key,
    required this.thresholdJagaddhitaMediumController,
    required this.percentJagaddhitaMediumController,
    required this.thresholdJagaddhitaHighController,
    required this.percentJagaddhitaHighController,
    required this.thresholdSibiController,
    required this.percentSibiController,
  });

  @override
  State<ProgressiveCommissionSettingsCard> createState() =>
      _ProgressiveCommissionSettingsCardState();
}

class _ProgressiveCommissionSettingsCardState
    extends State<ProgressiveCommissionSettingsCard> {
  String _formatCurrency(String text) {
    if (text.isEmpty) return 'Rp 0';
    final val = double.tryParse(text) ?? 0.0;
    return AppFormatters.currency(val.toInt());
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to rebuild and show dynamic currency preview below inputs
    widget.thresholdJagaddhitaMediumController.addListener(_onChanged);
    widget.thresholdJagaddhitaHighController.addListener(_onChanged);
    widget.thresholdSibiController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.thresholdJagaddhitaMediumController.removeListener(_onChanged);
    widget.thresholdJagaddhitaHighController.removeListener(_onChanged);
    widget.thresholdSibiController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Komisi Progresif Jagaddhita',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Aturan diskon khusus berdasarkan volume pesanan bruto',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Jagaddhita Medium (Default 20Jt -> 60%)
          Text(
            'Tingkat Menengah (Buku Jagaddhita)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: widget.thresholdJagaddhitaMediumController,
            keyboardType: TextInputType.number,
            label: 'Threshold Bruto (Rupiah)',
            icon: Icons.money,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 12),
            child: Text(
              _formatCurrency(widget.thresholdJagaddhitaMediumController.text),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppTextField(
            controller: widget.percentJagaddhitaMediumController,
            keyboardType: TextInputType.number,
            label: 'Persentase Diskon Baru (%)',
            icon: Icons.percent,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Section 2: Jagaddhita High (Default 50Jt -> 70%)
          Text(
            'Tingkat Tinggi (Buku Jagaddhita)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: widget.thresholdJagaddhitaHighController,
            keyboardType: TextInputType.number,
            label: 'Threshold Bruto (Rupiah)',
            icon: Icons.money,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 12),
            child: Text(
              _formatCurrency(widget.thresholdJagaddhitaHighController.text),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppTextField(
            controller: widget.percentJagaddhitaHighController,
            keyboardType: TextInputType.number,
            label: 'Persentase Diskon Baru (%)',
            icon: Icons.percent,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Section 3: Buku SIBI Kemendikbud (Default 10Jt -> 50%)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Buku SIBI Nonteks Kemendikbudristek',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: widget.thresholdSibiController,
            keyboardType: TextInputType.number,
            label: 'Threshold Bruto (Rupiah)',
            icon: Icons.money,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 12),
            child: Text(
              _formatCurrency(widget.thresholdSibiController.text),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppTextField(
            controller: widget.percentSibiController,
            keyboardType: TextInputType.number,
            label: 'Persentase Diskon Baru (%)',
            icon: Icons.percent,
          ),
        ],
      ),
    );
  }
}
