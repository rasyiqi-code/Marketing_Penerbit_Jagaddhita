import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'catalog_modal.dart';

class ProductPickerField extends StatelessWidget {
  final List<ProductModel> products;
  final List<ProductModel> selectedProducts;
  final ValueChanged<List<ProductModel>> onChanged;
  final Color themeColor;

  const ProductPickerField({
    super.key,
    required this.products,
    required this.selectedProducts,
    required this.onChanged,
    required this.themeColor,
  });

  void _showCatalogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => CatalogModal(
        products: products,
        initialSelected: selectedProducts,
        onConfirmed: (picked) {
          onChanged(picked);
          Navigator.pop(ctx);
        },
        color: themeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    String? priceText;
    if (selectedProducts.isEmpty) {
      displayText = 'Tap untuk memilih buku...';
    } else if (selectedProducts.length == 1) {
      displayText = selectedProducts.first.name;
      priceText = AppFormatters.currency(selectedProducts.first.price);
    } else {
      displayText = '${selectedProducts.length} buku dipilih';
      final total =
          selectedProducts.fold<double>(0, (sum, p) => sum + p.price);
      priceText = AppFormatters.currency(total);
    }

    return InkWell(
      onTap: () => _showCatalogModal(context),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Pilih Buku',
          prefixIcon:
              Icon(Icons.shopping_bag_outlined, color: themeColor),
          suffixIcon:
              Icon(Icons.grid_view_rounded, color: themeColor),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: themeColor.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: themeColor, width: 2),
          ),
          filled: true,
          fillColor: themeColor.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.15
                : 0.05,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: selectedProducts.isEmpty
                      ? Theme.of(context).hintColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (priceText != null) ...[
              const SizedBox(width: 8),
              Text(
                priceText,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
