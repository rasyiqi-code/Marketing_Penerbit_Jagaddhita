import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Katalog Produk',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: const CatalogList(houseType: 1),
    );
  }
}

class CatalogList extends StatelessWidget {
  final int houseType;

  const CatalogList({super.key, required this.houseType});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);

    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(houseType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text('Belum ada produk tersedia.'),
              ],
            ),
          );
        }

        final products = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 120),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _CatalogBookCard(product: product, houseType: houseType);
          },
        );
      },
    );
  }
}

class _CatalogBookCard extends StatefulWidget {
  final ProductModel product;
  final int houseType;

  const _CatalogBookCard({
    required this.product,
    required this.houseType,
  });

  @override
  State<_CatalogBookCard> createState() => _CatalogBookCardState();
}

class _CatalogBookCardState extends State<_CatalogBookCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/catalog/detail',
            arguments: widget.product,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : (_hovered ? 0.08 : 0.03)),
                blurRadius: _hovered ? 12 : 6,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: _hovered
                  ? AppTheme.primaryColor.withValues(alpha: 0.4)
                  : Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover Image on Left
                SizedBox(
                  width: 75,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCover(widget.product),
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
                              widget.product.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        // Rating, Price, and Badges row
                        Row(
                          children: [
                            Text(
                              '4,9',
                              style: TextStyle(
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
                              AppFormatters.currency(widget.product.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Marketing Kit Badge if available
                            if (widget.product.marketingKitUrl != null && widget.product.marketingKitUrl!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.download_rounded,
                                      size: 10,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Kit',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
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
      ),
    );
  }

  Widget _buildCover(ProductModel book) {
    final imageUrl = (book.imageUrl != null && book.imageUrl!.isNotEmpty)
        ? book.imageUrl!
        : (book.marketingKitUrl != null && book.marketingKitUrl!.isNotEmpty)
            ? book.marketingKitUrl!
            : null;

    if (imageUrl != null) {
      return NetworkImageWeb(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: _CoverFallback(houseType: widget.houseType),
      );
    }
    return _CoverFallback(houseType: widget.houseType);
  }
}

class _CoverFallback extends StatelessWidget {
  final int houseType;
  const _CoverFallback({required this.houseType});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (houseType == 1 ? AppTheme.primaryColor : AppTheme.secondaryColor).withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          houseType == 1 ? Icons.menu_book_rounded : Icons.brush_rounded,
          size: 32,
          color: (houseType == 1 ? AppTheme.primaryColor : AppTheme.secondaryColor).withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
