import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/add_edit_product_screen.dart';

class AdminProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductService productService;
  final int houseType;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.productService,
    required this.houseType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditProductScreen(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Product Image / Icon
                Hero(
                  tag: 'product_${product.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: houseType == 1
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : AppTheme.secondaryColor.withValues(alpha: 0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if ((product.marketingKitUrl != null &&
                                  product.marketingKitUrl!.isNotEmpty) ||
                              (product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty))
                            NetworkImageWeb(
                              imageUrl: (product.marketingKitUrl != null &&
                                      product.marketingKitUrl!.isNotEmpty)
                                  ? product.marketingKitUrl!
                                  : product.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Icon(
                                houseType == 1
                                    ? Icons.menu_book_rounded
                                    : Icons.brush_rounded,
                                color: houseType == 1
                                    ? AppTheme.primaryColor
                                    : AppTheme.secondaryColor,
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(product.price),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditProductScreen(product: product),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () async {
                        final confirm = await AppDialogs.showConfirmDialog(
                          context: context,
                          title: 'Hapus Produk',
                          content: 'Apakah Anda yakin ingin menghapus "${product.name}"?',
                          confirmLabel: 'Hapus',
                          cancelLabel: 'Batal',
                          isDanger: true,
                        );
                        if (confirm == true) {
                          await productService.deleteProduct(product.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
