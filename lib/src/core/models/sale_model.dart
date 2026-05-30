import 'package:cloud_firestore/cloud_firestore.dart';

class SaleHistoryItem {
  final String status;
  final String? note;
  final DateTime timestamp;
  final String actor; // 'Admin', 'Marketing', 'System'

  SaleHistoryItem({
    required this.status,
    this.note,
    required this.timestamp,
    required this.actor,
  });

  factory SaleHistoryItem.fromMap(Map<String, dynamic> map) {
    return SaleHistoryItem(
      status: map['status'] ?? '',
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actor: map['actor'] ?? 'System',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'actor': actor,
    };
  }
}

class SaleModel {
  final String id;
  final String userId;
  final String productId;
  final Map<String, dynamic> details;
  final double totalPrice;
  final String paymentStatus; // DP, LUNAS, PENDING, CANCELED, COMPLETE, PROBLEM
  final double bonusAmount; // General/Legacy total bonus
  final double commissionAmount; // Specific Commission (Cash)
  final int? commissionEarned;
  final int? markupPerQty;
  final int? totalMarkup; // Specific Commission (Cash)
  final double pulsaBonusAmount; // Specific Pulsa (Credit)
  final double paidAmount; // Amount currently paid (DP or Full)
  final DateTime createdAt;
  final String? transactionProofUrl;
  final List<SaleHistoryItem> history; // New history field
  final String? shippingStatus; // DISIAPKAN, DIKIRIM, SAMPAI, SELESAI
  final String? shippingResi;
  final String? shippingCourier;

  static const String statusPending = 'PENDING';
  static const String statusDp = 'DP';
  static const String statusCod = 'COD';
  static const String statusLunas = 'LUNAS';
  static const String statusComplete = 'COMPLETE';
  static const String statusProblem = 'PROBLEM';
  static const String statusCanceled = 'CANCELED';

  // Helper getters for new transaction fields
  String get customerName => details['customer_name'] ?? details['nama_pemesan'] ?? '-';
  String get customerPhone => details['customer_phone'] ?? details['telepon_penerima'] ?? '-';
  
  List<int> get productQuantities {
    if (details['product_quantities'] != null) {
      return List<int>.from(details['product_quantities']);
    }
    // Fallback for legacy orders: replicate single qty for each product ID
    final productIdsList = productIds;
    final legacyQty = details['quantity'] as int? ?? 1;
    return List<int>.filled(productIdsList.length, legacyQty);
  }

  List<String> get productIds {
    if (details['product_ids'] != null) {
      return List<String>.from(details['product_ids']);
    }
    return [productId];
  }

  List<String> get productNames {
    if (details['product_names'] != null) {
      return List<String>.from(details['product_names']);
    }
    return [details['product_name'] ?? 'Produk'];
  }

  List<double> get productPrices {
    if (details['product_prices'] != null) {
      return List<double>.from(details['product_prices'].map((e) => (e as num).toDouble()));
    }
    return [(details['product_price'] as num? ?? totalPrice).toDouble()];
  }

  SaleModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.details,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bonusAmount,
    required this.createdAt,
    this.commissionAmount = 0.0,
    this.commissionEarned,
    this.markupPerQty,
    this.totalMarkup,
    this.pulsaBonusAmount = 0.0,
    this.paidAmount = 0,
    this.transactionProofUrl,
    this.history = const [],
    this.shippingStatus,
    this.shippingResi,
    this.shippingCourier,
  });

  factory SaleModel.fromMap(Map<String, dynamic> data, String id) {
    return SaleModel(
      id: id,
      userId: data['user_id'] ?? '',
      productId: data['product_id'] ?? '',
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      paymentStatus: data['payment_status'] ?? statusPending,
      bonusAmount: (data['bonus_amount'] ?? 0).toDouble(),
      commissionAmount: (data['commission_amount'] ?? 0).toDouble(),
      commissionEarned: (data['commission_earned'] ?? 0),
      markupPerQty: (data['markup_per_qty'] ?? 0),
      totalMarkup: (data['total_markup'] ?? 0),
      pulsaBonusAmount: (data['pulsa_bonus_amount'] ?? 0).toDouble(),
      paidAmount: (data['paid_amount'] ?? 0).toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionProofUrl: data['transaction_proof_url'],
      history:
          (data['history'] as List<dynamic>?)
              ?.map((e) => SaleHistoryItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingStatus: data['shipping_status'],
      shippingResi: data['shipping_resi'],
      shippingCourier: data['shipping_courier'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'product_id': productId,
      'details': details,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'bonus_amount': bonusAmount,
      'commission_amount': commissionAmount,
      'commission_earned': commissionEarned,
      'markup_per_qty': markupPerQty,
      'total_markup': totalMarkup,
      'pulsa_bonus_amount': pulsaBonusAmount,
      'paid_amount': paidAmount,
      'created_at': Timestamp.fromDate(createdAt),
      'transaction_proof_url': transactionProofUrl,
      'history': history.map((e) => e.toMap()).toList(),
      if (shippingStatus != null) 'shipping_status': shippingStatus,
      if (shippingResi != null) 'shipping_resi': shippingResi,
      if (shippingCourier != null) 'shipping_courier': shippingCourier,
    };
  }
}
