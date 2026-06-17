import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'placeholder_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final bool isMultiSelectMode;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? (isSelected
            ? color.withValues(alpha: 0.25)
            : const Color(0xFF2A2A3E))
        : (isSelected
            ? color.withValues(alpha: 0.08)
            : Colors.white);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Image on Left with checkmark stacks
              SizedBox(
                width: 75,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCover(product, color),
                      
                      // Multi-select checkbox overlay
                      if (isMultiSelectMode)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isSelected
                                      ? color
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : Colors.black.withValues(alpha: 0.3)),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                        ),

                      // Selected checkmark (non-multi mode)
                      if (!isMultiSelectMode && isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Book Details on Right
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? color
                                  : Theme.of(context).colorScheme.onSurface,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      // Rating & Price row
                      Row(
                        children: [
                          Text(
                            '4,9',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatters.currency(product.price),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : AppTheme.primaryColor,
                            ),
                          ),
                          if (product.category.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(ProductModel book, Color fallbackColor) {
    final imageUrl = (book.imageUrl != null && book.imageUrl!.isNotEmpty)
        ? book.imageUrl!
        : (book.marketingKitUrl != null && book.marketingKitUrl!.isNotEmpty)
            ? book.marketingKitUrl!
            : null;

    if (imageUrl != null) {
      return NetworkImageWeb(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: PlaceholderImage(color: fallbackColor),
      );
    }
    return PlaceholderImage(color: fallbackColor);
  }
}
