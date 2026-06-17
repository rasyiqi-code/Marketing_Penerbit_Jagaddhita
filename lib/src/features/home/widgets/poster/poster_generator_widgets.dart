import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Interactive custom horizontal color picker.
class PosterColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  const PosterColorPicker({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      const Color(0xFF333333),
      const Color(0xFFDAA520),
      const Color(0xFF1B5E20),
      const Color(0xFF0D47A1),
      const Color(0xFFB71C1C),
    ];

    return Wrap(
      spacing: 12,
      children: colors
          .map(
            (col) => GestureDetector(
              onTap: () => onSelected(col),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: col,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == col
                        ? AppTheme.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: selectedColor == col ? 3 : 1,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Font size tier chips (Small, Medium, Large).
class PosterFontTierChips extends StatelessWidget {
  final int fontTier;
  final ValueChanged<int> onChanged;

  const PosterFontTierChips({
    super.key,
    required this.fontTier,
    required this.onChanged,
  });

  Widget _buildTierChip(int tier, String label) {
    final isSelected = fontTier == tier;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(tier);
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTierChip(1, 'Kecil'),
        const SizedBox(width: 8),
        _buildTierChip(2, 'Sedang'),
        const SizedBox(width: 8),
        _buildTierChip(3, 'Besar'),
      ],
    );
  }
}

/// The initial state when no poster/image is selected yet.
class PosterEmptyState extends StatelessWidget {
  final VoidCallback onPickImage;

  const PosterEmptyState({
    super.key,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_search, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'Pilih poster untuk dipersonalisasi',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Pilih dari Galeri'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Dynamic footer action buttons for poster generation screen.
class PosterBottomActions extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onDownload;

  const PosterBottomActions({
    super.key,
    required this.onPickImage,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Ganti'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The overlay text widget displaying customizable text that can be dragged.
class PosterOverlayText extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final double bgOpacity;
  final bool isBgEnabled;
  final int fontTier;

  const PosterOverlayText({
    super.key,
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.bgOpacity,
    required this.isBgEnabled,
    required this.fontTier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isBgEnabled
            ? bgColor.withValues(alpha: bgOpacity)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontTier == 3 ? 24 : (fontTier == 2 ? 16 : 10),
          fontWeight: FontWeight.bold,
          shadows: !isBgEnabled
              ? const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
