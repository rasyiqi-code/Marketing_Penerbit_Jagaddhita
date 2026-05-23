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
    // Use a column of rows (2 per row) so cards auto-size to content — no dead space.
    final rows = <Widget>[];
    for (int i = 0; i < books.length; i += 2) {
      final left = books[i];
      final right = (i + 1 < books.length) ? books[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BookCard(
                  book: left,
                  whatsappNumber: whatsappNumber,
                  onSendWhatsApp: onSendWhatsApp,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: right != null
                    ? _BookCard(
                        book: right,
                        whatsappNumber: whatsappNumber,
                        onSendWhatsApp: onSendWhatsApp,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < books.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.14 : 0.06),
                blurRadius: _hovered ? 16 : 8,
                offset: Offset(0, _hovered ? 6 : 2),
              ),
            ],
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF25D366).withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover image with hover overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCover(widget.book),
                      // Hover overlay: slides up from bottom
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        bottom: _hovered ? 0 : -60,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF1E8449).withValues(alpha: 0.95),
                                const Color(0xFF25D366).withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pesan via WA',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.book.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.book.name,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.currency(widget.book.price),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A9E52),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
