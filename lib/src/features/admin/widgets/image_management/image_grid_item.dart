import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

/// Satu item dalam grid gambar.
class ImageGridItem extends StatelessWidget {
  final String imageUrl;
  final String imageKey;
  final bool isSelected;
  final bool isPicker;
  final DateTime? lastModified;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ImageGridItem({
    super.key,
    required this.imageUrl,
    required this.imageKey,
    required this.isSelected,
    required this.isPicker,
    required this.onTap,
    required this.onLongPress,
    this.lastModified,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: NetworkImageWeb(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                child: const Center(
                  child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                DateFormat('dd/MM/yy').format(lastModified ?? DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
