import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/poster/poster_generator_widgets.dart';
class PosterStylePanel extends StatefulWidget {
  final Color initialTextColor;
  final Color initialBgColor;
  final double initialBgOpacity;
  final bool initialIsBgEnabled;
  final int initialFontTier;

  final ValueChanged<Color> onTextColorChanged;
  final ValueChanged<Color> onBgColorChanged;
  final ValueChanged<double> onBgOpacityChanged;
  final ValueChanged<bool> onIsBgEnabledChanged;
  final ValueChanged<int> onFontTierChanged;

  const PosterStylePanel({
    super.key,
    required this.initialTextColor,
    required this.initialBgColor,
    required this.initialBgOpacity,
    required this.initialIsBgEnabled,
    required this.initialFontTier,
    required this.onTextColorChanged,
    required this.onBgColorChanged,
    required this.onBgOpacityChanged,
    required this.onIsBgEnabledChanged,
    required this.onFontTierChanged,
  });

  @override
  State<PosterStylePanel> createState() => _PosterStylePanelState();
}

class _PosterStylePanelState extends State<PosterStylePanel> {
  late Color _textColor;
  late Color _bgColor;
  late double _bgOpacity;
  late bool _isBgEnabled;
  late int _fontTier;

  @override
  void initState() {
    super.initState();
    _textColor = widget.initialTextColor;
    _bgColor = widget.initialBgColor;
    _bgOpacity = widget.initialBgOpacity;
    _isBgEnabled = widget.initialIsBgEnabled;
    _fontTier = widget.initialFontTier;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kustomisasi Gaya',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gunakan Background'),
                Switch(
                  value: _isBgEnabled,
                  onChanged: (val) {
                    setState(() => _isBgEnabled = val);
                    widget.onIsBgEnabledChanged(val);
                  },
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),

            if (_isBgEnabled) ...[
              const Text('Warna Background'),
              const SizedBox(height: 8),
              PosterColorPicker(
                selectedColor: _bgColor,
                onSelected: (col) {
                  setState(() => _bgColor = col);
                  widget.onBgColorChanged(col);
                },
              ),
              const SizedBox(height: 16),
              Text('Opasitas Background: ${(_bgOpacity * 100).toInt()}%'),
              Slider(
                value: _bgOpacity,
                min: 0.1,
                max: 1.0,
                onChanged: (val) {
                  setState(() => _bgOpacity = val);
                  widget.onBgOpacityChanged(val);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],

            const Text('Warna Font'),
            const SizedBox(height: 8),
            PosterColorPicker(
              selectedColor: _textColor,
              onSelected: (col) {
                setState(() => _textColor = col);
                widget.onTextColorChanged(col);
              },
            ),

            const SizedBox(height: 16),
            const Text('Ukuran Font'),
            PosterFontTierChips(
              fontTier: _fontTier,
              onChanged: (tier) {
                setState(() => _fontTier = tier);
                widget.onFontTierChanged(tier);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
