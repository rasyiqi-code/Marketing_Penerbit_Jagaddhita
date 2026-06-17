import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'section_header.dart';
import 'product_card.dart';
import 'confirm_bar.dart';

class CatalogModal extends StatefulWidget {
  final List<ProductModel> products;
  final List<ProductModel> initialSelected;
  final ValueChanged<List<ProductModel>> onConfirmed;
  final Color color;

  const CatalogModal({
    super.key,
    required this.products,
    required this.initialSelected,
    required this.onConfirmed,
    required this.color,
  });

  @override
  State<CatalogModal> createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isMultiSelectMode = false;

  late final Set<String> _pickedIds;

  @override
  void initState() {
    super.initState();
    _pickedIds = widget.initialSelected.map((p) => p.id).toSet();
    if (_pickedIds.length > 1) _isMultiSelectMode = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final cats = <String>{'Semua'};
    for (final p in widget.products) {
      if (p.category.isNotEmpty) cats.add(p.category);
    }
    return cats.toList();
  }

  List<ProductModel> get _filtered => widget.products.where((p) {
        final matchesSearch = _searchQuery.isEmpty ||
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCat =
            _selectedCategory == 'Semua' || p.category == _selectedCategory;
        return matchesSearch && matchesCat;
      }).toList();

  List<ProductModel> get _jagaddhitaFiltered =>
      _filtered.where((p) => p.isJagaddhita).toList();
  List<ProductModel> get _sibiFiltered =>
      _filtered.where((p) => p.isSibi).toList();

  List<ProductModel> get _pickedProducts =>
      widget.products.where((p) => _pickedIds.contains(p.id)).toList();

  double get _pickedTotal =>
      _pickedProducts.fold(0, (sum, p) => sum + p.price);

  void _handleTap(ProductModel product) {
    if (_isMultiSelectMode) {
      setState(() {
        if (_pickedIds.contains(product.id)) {
          _pickedIds.remove(product.id);
        } else {
          _pickedIds.add(product.id);
        }
      });
    } else {
      widget.onConfirmed([product]);
    }
  }

  void _handleLongPress(ProductModel product) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMultiSelectMode = true;
      _pickedIds.add(product.id);
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _isMultiSelectMode = false;
      _pickedIds.clear();
    });
  }

  void _confirm() {
    if (_pickedIds.isEmpty) return;
    widget.onConfirmed(_pickedProducts);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final pickedCount = _pickedIds.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isMultiSelectMode
                          ? IconButton(
                              key: const ValueKey('exit'),
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Keluar mode pilih banyak',
                              onPressed: _exitMultiSelect,
                            )
                          : Padding(
                              key: const ValueKey('icon'),
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      widget.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.library_books_rounded,
                                    color: widget.color, size: 22),
                              ),
                            ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isMultiSelectMode
                                ? Row(
                                    key: const ValueKey('multi'),
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: widget.color,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'PILIH BANYAK',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$pickedCount terpilih',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    key: const ValueKey('single'),
                                    'Katalog Buku',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                          ),
                          Text(
                            _isMultiSelectMode
                                ? 'Tahan untuk memilih • Ketuk untuk toggle'
                                : '${widget.products.length} paket tersedia • Tahan untuk pilih banyak',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isMultiSelectMode)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.outfit(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk atau kategori...',
                    hintStyle: GoogleFonts.outfit(fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? widget.color
                              : (isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 60,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              'Produk tidak ditemukan',
                              style: GoogleFonts.outfit(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                            16, 16, 16, _isMultiSelectMode ? 96 : 16),
                        children: [
                          if (_jagaddhitaFiltered.isNotEmpty) ...[
                            SectionHeader(
                              icon: Icons.menu_book_rounded,
                              title: 'Buku Jagaddhita Media Pustaka',
                              subtitle: 'Buku Paket & Buku Cerita',
                              color: widget.color,
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: _jagaddhitaFiltered.map((product) {
                                final isPicked =
                                    _pickedIds.contains(product.id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ProductCard(
                                    product: product,
                                    isSelected: isPicked,
                                    isMultiSelectMode: _isMultiSelectMode,
                                    color: widget.color,
                                    onTap: () => _handleTap(product),
                                    onLongPress: () =>
                                        _handleLongPress(product),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (_sibiFiltered.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            SectionHeader(
                              icon: Icons.school_rounded,
                              title: 'Buku SIBI Kemendikbud',
                              subtitle: 'Buku Nonteks Kemendikbudristek',
                              color: Colors.indigo,
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: _sibiFiltered.map((product) {
                                final isPicked =
                                    _pickedIds.contains(product.id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ProductCard(
                                    product: product,
                                    isSelected: isPicked,
                                    isMultiSelectMode: _isMultiSelectMode,
                                    color: Colors.indigo,
                                    onTap: () => _handleTap(product),
                                    onLongPress: () =>
                                        _handleLongPress(product),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
              ),
              AnimatedSlide(
                offset: _isMultiSelectMode ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _isMultiSelectMode ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _isMultiSelectMode
                      ? ConfirmBar(
                          pickedCount: pickedCount,
                          total: _pickedTotal,
                          color: widget.color,
                          onCancel: _exitMultiSelect,
                          onConfirm: _confirm,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
