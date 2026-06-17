import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

/// Renders the Hero product image with safe fallback.
class ProductDetailImage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailImage({super.key, required this.product});

  @override
  State<ProductDetailImage> createState() => _ProductDetailImageState();
}

class _ProductDetailImageState extends State<ProductDetailImage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrls;
    final fallbackImages = (images.isEmpty &&
            widget.product.marketingKitUrl != null &&
            widget.product.marketingKitUrl!.isNotEmpty)
        ? [widget.product.marketingKitUrl!]
        : images;

    if (fallbackImages.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Theme.of(context).cardColor,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return Hero(
      tag: 'product_${widget.product.id}',
      child: Container(
        height: 360,
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.product.houseType == 1
              ? AppTheme.primaryColor.withValues(alpha: 0.05)
              : AppTheme.secondaryColor.withValues(alpha: 0.05),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 3 / 4, // Rasio aspek buku portrait standard
                      child: PageView.builder(
                        itemCount: fallbackImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return NetworkImageWeb(
                            imageUrl: fallbackImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover, // Memenuhi rasio buku dengan rapi
                            errorWidget: Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (fallbackImages.length > 1)
              Positioned(
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    fallbackImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Renders the badges, product name, and standard formatted pricing.
class ProductDetailHeader extends StatelessWidget {
  final ProductModel product;

  const ProductDetailHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (product.houseType == 1 ? AppTheme.primaryColor : AppTheme.secondaryColor)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Penerbit Jagaddhita',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Text(
                product.category,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp',
            decimalDigits: 0,
          ).format(product.price),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

/// Renders the product description header and content.
class ProductDetailDescription extends StatelessWidget {
  final String description;

  const ProductDetailDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi Produk',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: GoogleFonts.outfit(
            fontSize: 13,
            height: 1.5,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Renders the marketing kit download tile, poster personalization button, and copywriting sections.
class ProductDetailMarketingKit extends StatelessWidget {
  final ProductModel product;

  const ProductDetailMarketingKit({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasKit = product.marketingKitUrl != null && product.marketingKitUrl!.isNotEmpty;
    final hasCopy = product.copywriting != null && product.copywriting!.isNotEmpty;

    if (!hasKit && !hasCopy) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marketing Kits',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),

        // Poster Image kit card link
        if (hasKit) ...[
          InkWell(
            onTap: () async {
              final url = Uri.parse(product.marketingKitUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poster / Gambar Produk',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Tap untuk melihat atau download gambar',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/poster_generator',
                arguments: product.marketingKitUrl,
              );
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Personalisasi Poster Ini'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],

        if (hasKit && hasCopy) const SizedBox(height: 16),

        // Copywriting Promotion Block
        if (hasCopy)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.copy_all_rounded,
                            size: 18,
                            color: Colors.white24, // Translucent white to perfectly match brand guideline
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Promo Copywriting',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: product.copywriting!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Teks promosi berhasil disalin!',
                                style: GoogleFonts.outfit(),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Salin Teks',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    product.copywriting!,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
