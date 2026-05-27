import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String userId; // Owner agent's user ID
  final String name;
  final String phoneNumber;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
