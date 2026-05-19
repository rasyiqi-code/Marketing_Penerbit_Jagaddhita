import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:provider/provider.dart';

/// Dynamic book catalog section for the link bio preview page.
/// Streams products from Firestore and renders a grid filtered by user preferences.
class LinkBioBookCatalogSection extends StatelessWidget {
  final UserModel user;
  final void Function(String? number, String message) onSendWhatsApp;

  const LinkBioBookCatalogSection({
    super.key,
    required this.user,
    required this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);

    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(1),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allProducts = snapshot.data!;

        bool isSibiBook(ProductModel p) =>
            p.category.toLowerCase().contains('sibi') ||
            p.category.toLowerCase().contains('kemendikbud') ||
            p.name.toLowerCase().contains('sibi');

        final jagaddhitaBooks =
            allProducts.where((p) => !isSibiBook(p)).toList();
        final sibiBooks = allProducts.where(isSibiBook).toList();

        final showJ = user.showJagaddhitaCatalog && jagaddhitaBooks.isNotEmpty;
        final showS = user.showSibiCatalog && sibiBooks.isNotEmpty;

        if (!showJ && !showS) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Katalog Buku Pilihan',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (showJ) ...[
              _CatalogHeader(
                title: 'Penerbit Jagaddhita Media Pustaka',
                icon: Icons.menu_book,
              ),
              const SizedBox(height: 12),
              _BooksGrid(books: jagaddhitaBooks, onSendWhatsApp: onSendWhatsApp, whatsappNumber: user.whatsappNumber),
              const SizedBox(height: 24),
            ],
            if (showS) ...[
              _CatalogHeader(
                title: 'SIBI Kurikulum Nonteks Kemendikbud',
                icon: Icons.school,
              ),
              const SizedBox(height: 12),
              _BooksGrid(books: sibiBooks, onSendWhatsApp: onSendWhatsApp, whatsappNumber: user.whatsappNumber),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CatalogHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class _BooksGrid extends StatelessWidget {
  final List<ProductModel> books;
  final String? whatsappNumber;
  final void Function(String? number, String message) onSendWhatsApp;

  const _BooksGrid({
    required this.books,
    required this.onSendWhatsApp,
    this.whatsappNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.54,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _BookCard(
        book: books[index],
        whatsappNumber: whatsappNumber,
        onSendWhatsApp: onSendWhatsApp,
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final ProductModel book;
  final String? whatsappNumber;
  final void Function(String? number, String message) onSendWhatsApp;

  const _BookCard({
    required this.book,
    required this.onSendWhatsApp,
    this.whatsappNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                Icons.book,
                size: 36,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.name,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.currency(book.price),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => onSendWhatsApp(
                            whatsappNumber,
                            'Halo Kak, saya tertarik untuk memesan buku "${book.name}" dari katalog digital Anda.',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Pesan',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
