import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/catalog/widgets/product_detail_widgets.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/share_helper.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! ProductModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: const Center(child: Text('Data produk tidak ditemukan.')),
      );
    }

    final ProductModel product = args;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: Text(
              'Detail Buku',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                  child: IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      final formattedPrice = NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(product.price);
                      
                      final shareText = '📚 *${product.name}*\n'
                          'Kategori: ${product.category}\n'
                          'Harga: $formattedPrice\n\n'
                          '${product.description}';
                      
                      nativeShare(context, shareText);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Product Image Container
          SliverToBoxAdapter(
            child: ProductDetailImage(product: product),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductDetailHeader(product: product),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  ProductDetailDescription(description: product.description),
                  const SizedBox(height: 12),
                  ProductDetailMarketingKit(product: product),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
