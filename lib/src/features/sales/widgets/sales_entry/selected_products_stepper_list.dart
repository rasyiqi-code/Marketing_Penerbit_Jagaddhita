import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Daftar buku terpilih yang dilengkapi stepper untuk mengatur jumlah pesanan.
class SelectedProductsStepperList extends StatelessWidget {
  final List<ProductModel> selectedProducts;
  final Map<String, int> selectedProductQuantities;
  final void Function(ProductModel product, int newQty) onQuantityChanged;

  const SelectedProductsStepperList({
    super.key,
    required this.selectedProducts,
    required this.selectedProductQuantities,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedProducts.length,
      itemBuilder: (ctx, idx) {
        final product = selectedProducts[idx];
        final qty = selectedProductQuantities[product.id] ?? 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (product.isSibi ? Colors.indigo : AppTheme.primaryColor)
                  .withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (product.isSibi ? Colors.indigo : AppTheme.primaryColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  product.isSibi ? Icons.account_balance : Icons.menu_book_rounded,
                  color: product.isSibi ? Colors.indigo : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.currency(product.price)} • ${product.category}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                    onPressed: qty > 1 ? () => onQuantityChanged(product, qty - 1) : null,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    alignment: Alignment.center,
                    child: Text(
                      '$qty',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    onPressed: () => onQuantityChanged(product, qty + 1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
