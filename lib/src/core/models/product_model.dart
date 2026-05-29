class ProductModel {
  final String id;
  final int houseType; // 1 = Penerbit Jagaddhita
  final String name;
  final String category;
  final double price;
  final String description;
  final String? imageUrl;
  final String? marketingKitUrl;
  final String? copywriting;
  final bool isSibi;

  ProductModel({
    required this.id,
    required this.houseType,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.imageUrl,
    this.marketingKitUrl,
    this.copywriting,
    this.isSibi = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    final categoryStr = data['category'] ?? '';
    final nameStr = data['name'] ?? '';
    final fallbackIsSibi = categoryStr.toLowerCase().contains('sibi') ||
        categoryStr.toLowerCase().contains('kemendikbud') ||
        nameStr.toLowerCase().contains('sibi');

    return ProductModel(
      id: id,
      houseType: data['house_type'] ?? 1,
      name: nameStr,
      category: categoryStr,
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['image_url'],
      marketingKitUrl: data['marketing_kit_url'],
      copywriting: data['copywriting'],
      isSibi: data['is_sibi'] ?? fallbackIsSibi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'house_type': houseType,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'marketing_kit_url': marketingKitUrl,
      'copywriting': copywriting,
      'is_sibi': isSibi,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Produk Jagaddhita Media Pustaka (Buku Paket & Buku Cerita).
  bool get isJagaddhita => !isSibi;
}
