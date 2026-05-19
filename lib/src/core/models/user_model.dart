class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' or 'marketing'
  final String? name;
  final String? username; // Unique handle for profile URL
  final String? photoUrl; // Profile picture URL
  final int commissionBalance;
  final int markupBalance;
  final int pulsaBalance;
  final int totalSalesCount;
  final int totalCommissionEarned; // All-time historic
  final int totalPulsaEarned; // All-time historic
  final DateTime? createdAt;
  final String? ktpNumber;
  final String? address;
  final String? phoneNumber;
  final Map<String, dynamic>? bankDetails;
  final String? marketingCategory; // 'reseller', 'distributor', or null

  // Custom Catalogs & Digital Business Card settings (New)
  final bool showJagaddhitaCatalog;
  final bool showSibiCatalog;
  final String? whatsappNumber;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? facebookUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.username,
    this.photoUrl,
    this.ktpNumber,
    this.address,
    this.phoneNumber,
    this.commissionBalance = 0,
    this.markupBalance = 0,
    this.pulsaBalance = 0,
    this.totalSalesCount = 0,
    this.totalCommissionEarned = 0,
    this.totalPulsaEarned = 0,
    this.createdAt,
    this.bankDetails,
    this.marketingCategory,
    this.showJagaddhitaCatalog = true,
    this.showSibiCatalog = true,
    this.whatsappNumber,
    this.instagramUrl,
    this.tiktokUrl,
    this.facebookUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'marketing',
      name: data['name'],
      username: data['username'],
      photoUrl: data['photo_url'],
      ktpNumber: data['ktp_number'],
      address: data['address'],
      phoneNumber: data['phone_number'],
      commissionBalance: (data['commission_balance'] ?? 0).toInt(),
      markupBalance: (data['markup_balance'] ?? 0).toInt(),
      pulsaBalance: (data['pulsa_balance'] ?? 0).toInt(),
      totalSalesCount: (data['total_sales_count'] ?? 0).toInt(),
      totalCommissionEarned: (data['total_commission_earned'] ?? 0).toInt(),
      totalPulsaEarned: (data['total_pulsa_earned'] ?? 0).toInt(),
      createdAt: data['created_at'] != null
          ? (data['created_at'] as dynamic).toDate()
          : null,
      bankDetails: data['bank_details'] != null
          ? Map<String, dynamic>.from(data['bank_details'])
          : null,
      marketingCategory: data['marketing_category'],
      showJagaddhitaCatalog: data['show_jagaddhita_catalog'] ?? true,
      showSibiCatalog: data['show_sibi_catalog'] ?? true,
      whatsappNumber: data['whatsapp_number'],
      instagramUrl: data['instagram_url'],
      tiktokUrl: data['tiktok_url'],
      facebookUrl: data['facebook_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'username': username,
      'photo_url': photoUrl,
      'ktp_number': ktpNumber,
      'address': address,
      'phone_number': phoneNumber,
      'commission_balance': commissionBalance,
      'markup_balance': markupBalance,
      'pulsa_balance': pulsaBalance,
      'total_sales_count': totalSalesCount,
      'total_commission_earned': totalCommissionEarned,
      'total_pulsa_earned': totalPulsaEarned,
      'created_at': createdAt,
      'bank_details': bankDetails,
      'marketing_category': marketingCategory,
      'show_jagaddhita_catalog': showJagaddhitaCatalog,
      'show_sibi_catalog': showSibiCatalog,
      'whatsapp_number': whatsappNumber,
      'instagram_url': instagramUrl,
      'tiktok_url': tiktokUrl,
      'facebook_url': facebookUrl,
    };
  }
}
