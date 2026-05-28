import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
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
    return Column(
      children: books.map((book) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _BookCard(
          book: book,
          whatsappNumber: whatsappNumber,
          onSendWhatsApp: onSendWhatsApp,
        ),
      )).toList(),
    );
  }
}

class _BookCard extends StatefulWidget {
  final ProductModel book;
  final String? whatsappNumber;
  final void Function(String? number, String message) onSendWhatsApp;

  const _BookCard({
    required this.book,
    required this.onSendWhatsApp,
    this.whatsappNumber,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSendWhatsApp(
          widget.whatsappNumber,
          'Halo Kak, saya tertarik untuk memesan buku "${widget.book.name}" dari katalog digital Anda.',
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.05),
                blurRadius: _hovered ? 12 : 6,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF25D366).withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.08),
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
                    child: _buildCover(widget.book),
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
                              widget.book.name,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.book.description,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.black54,
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
                                color: Colors.black54,
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
                              AppFormatters.currency(widget.book.price),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A9E52),
                              ),
                            ),
                            const Spacer(),
                            // Small WhatsApp Icon indicator on the right
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _hovered
                                    ? const Color(0xFF25D366).withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 12,
                                color: _hovered
                                    ? const Color(0xFF1E8449)
                                    : Colors.black45,
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
        errorWidget: _CoverFallback(),
      );
    }
    return _CoverFallback();
  }
}

class _CoverFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 36,
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
