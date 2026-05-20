import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget — drop‑in replacement for the old ProductPickerField.
// onChanged now receives a List<ProductModel> (single tap = list of 1,
// long‑press multi‑select = list of N).
// ─────────────────────────────────────────────────────────────────────────────

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
      builder: (ctx) => _CatalogModal(
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

// ─────────────────────────────────────────────────────────────────────────────
// Internal full‑screen catalog modal
// ─────────────────────────────────────────────────────────────────────────────

class _CatalogModal extends StatefulWidget {
  final List<ProductModel> products;
  final List<ProductModel> initialSelected;
  final ValueChanged<List<ProductModel>> onConfirmed;
  final Color color;

  const _CatalogModal({
    required this.products,
    required this.initialSelected,
    required this.onConfirmed,
    required this.color,
  });

  @override
  State<_CatalogModal> createState() => _CatalogModalState();
}

class _CatalogModalState extends State<_CatalogModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isMultiSelectMode = false;

  // Tracks ids currently selected inside the modal session
  late final Set<String> _pickedIds;

  @override
  void initState() {
    super.initState();
    _pickedIds = widget.initialSelected.map((p) => p.id).toSet();
    // If initial selection has >1, start directly in multi‑select mode
    if (_pickedIds.length > 1) _isMultiSelectMode = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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
      // Toggle selection
      setState(() {
        if (_pickedIds.contains(product.id)) {
          _pickedIds.remove(product.id);
        } else {
          _pickedIds.add(product.id);
        }
      });
    } else {
      // Single‑select → confirm immediately
      widget.onConfirmed([product]);
    }
  }

  void _handleLongPress(ProductModel product) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMultiSelectMode = true;
      _pickedIds.add(product.id); // Add the long‑pressed item
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? const Color(0xFF1E1E2E) : Colors.white;
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
              // ── Drag handle ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Header ──────────────────────────────────────────────
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
                        onPressed: () => Navigator.pop(ctx),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Search bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.outfit(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk atau kategori...',
                    hintStyle: GoogleFonts.outfit(fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear_rounded, size: 18),
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
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Category chips ─────────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
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
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),

              // ── Product List (Grouped) ──────────────────────────────
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
                          // ── Buku Jagaddhita Section ──────────────────
                          if (_jagaddhitaFiltered.isNotEmpty) ...[
                            _SectionHeader(
                              icon: '📚',
                              title: 'Buku Jagaddhita Media Pustaka',
                              subtitle: 'Buku Paket & Buku Cerita',
                              color: widget.color,
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _jagaddhitaFiltered.length,
                              itemBuilder: (_, i) {
                                final product =
                                    _jagaddhitaFiltered[i];
                                final isPicked =
                                    _pickedIds.contains(product.id);
                                return _ProductCard(
                                  product: product,
                                  isSelected: isPicked,
                                  isMultiSelectMode: _isMultiSelectMode,
                                  color: widget.color,
                                  onTap: () => _handleTap(product),
                                  onLongPress: () =>
                                      _handleLongPress(product),
                                );
                              },
                            ),
                          ],
                          // ── Buku SIBI Section ────────────────────────
                          if (_sibiFiltered.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _SectionHeader(
                              icon: '🏛️',
                              title: 'Buku SIBI Kemendikbud',
                              subtitle: 'Buku Nonteks Kemendikbudristek',
                              color: Colors.indigo,
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _sibiFiltered.length,
                              itemBuilder: (_, i) {
                                final product = _sibiFiltered[i];
                                final isPicked =
                                    _pickedIds.contains(product.id);
                                return _ProductCard(
                                  product: product,
                                  isSelected: isPicked,
                                  isMultiSelectMode: _isMultiSelectMode,
                                  color: Colors.indigo,
                                  onTap: () => _handleTap(product),
                                  onLongPress: () =>
                                      _handleLongPress(product),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
              ),

              // ── Confirm bar (multi‑select only) ────────────────────
              AnimatedSlide(
                offset: _isMultiSelectMode
                    ? Offset.zero
                    : const Offset(0, 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _isMultiSelectMode ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _isMultiSelectMode
                      ? _ConfirmBar(
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

// ─────────────────────────────────────────────────────────────────────────────
// Confirm bar (sticky bottom bar in multi‑select mode)
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  final int pickedCount;
  final double total;
  final Color color;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.pickedCount,
    required this.total,
    required this.color,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pickedCount paket dipilih',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Total: ${AppFormatters.currency(total)}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    pickedCount == 0 ? Theme.of(context).disabledColor : color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: pickedCount == 0 ? null : onConfirm,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Konfirmasi',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Product Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final bool isMultiSelectMode;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? (isSelected
            ? color.withValues(alpha: 0.25)
            : const Color(0xFF2A2A3E))
        : (isSelected
            ? color.withValues(alpha: 0.08)
            : Colors.white);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(9)),
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _PlaceholderImage(color: color),
                          )
                        : _PlaceholderImage(color: color),
                  ),

                  // Multi‑select checkbox overlay
                  if (isMultiSelectMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? color
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.3)),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),

                  // Selected checkmark (non‑multi mode)
                  if (!isMultiSelectMode && isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),

                  // Category chip
                  if (product.category.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: isMultiSelectMode ? 44 : 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.category,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Product Info ─────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? color
                            : Theme.of(context)
                                .colorScheme
                                .onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppFormatters.currency(product.price),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? color
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final Color color;
  const _PlaceholderImage({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header for catalog grouping
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
