class ProductModel {
  final String id;
  final int houseType; // 1 = Penerbit Jagaddhita
  final String name;
  final String category;
  final double price;
  final String description;
  final List<String> imageUrls;
  final String? marketingKitUrl;
  final String? copywriting;
  final bool isSibi;

  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  ProductModel({
    required this.id,
    required this.houseType,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    String? imageUrl,
    List<String>? imageUrls,
    this.marketingKitUrl,
    this.copywriting,
    this.isSibi = false,
  }) : imageUrls = imageUrls ?? (imageUrl != null && imageUrl.isNotEmpty ? [imageUrl] : const []);

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    final categoryStr = data['category'] ?? '';
    final nameStr = data['name'] ?? '';
    final fallbackIsSibi = categoryStr.toLowerCase().contains('sibi') ||
        categoryStr.toLowerCase().contains('kemendikbud') ||
        nameStr.toLowerCase().contains('sibi');

    final rawImageUrls = data['image_urls'];
    List<String> imageUrlsList = [];
    if (rawImageUrls is List) {
      imageUrlsList = rawImageUrls.map((e) => e.toString()).toList();
    } else if (data['image_url'] != null && data['image_url'].toString().isNotEmpty) {
      imageUrlsList = [data['image_url'].toString()];
    }

    return ProductModel(
      id: id,
      houseType: data['house_type'] ?? 1,
      name: nameStr,
      category: categoryStr,
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrls: imageUrlsList,
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
      'image_url': imageUrls.isNotEmpty ? imageUrls.first : null,
      'image_urls': imageUrls,
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
