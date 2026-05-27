import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/customer_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class CustomerService extends BaseFirestoreService {
  CustomerService({super.firestore});

  /// Streams list of customers belonging to the active marketing agent, sorted alphabetically.
  Stream<List<CustomerModel>> getCustomers(String userId) {
    return db
        .collection('customers')
        .where('user_id', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Manually inserts a customer record.
  Future<DocumentReference> addCustomer(CustomerModel customer) {
    return db.collection('customers').add(customer.toMap());
  }

  /// Searches for a customer by their phone number under the agent's account.
  Future<CustomerModel?> findCustomerByPhone(String userId, String phoneNumber) async {
    final cleanPhone = phoneNumber.trim().replaceAll(RegExp(r'\s+'), '');
    final query = await db
        .collection('customers')
        .where('user_id', isEqualTo: userId)
        .where('phone_number', isEqualTo: cleanPhone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return CustomerModel.fromMap(
        query.docs.first.data(),
        query.docs.first.id,
      );
    }
    return null;
  }

  /// Automatically registers a customer during a transaction if they don't already exist under the agent's ID.
  Future<void> saveCustomerIfNew(String userId, String name, String phoneNumber) async {
    if (name.trim().isEmpty || phoneNumber.trim().isEmpty) return;

    final cleanPhone = phoneNumber.trim().replaceAll(RegExp(r'\s+'), '');
    final existing = await findCustomerByPhone(userId, cleanPhone);

    if (existing == null) {
      final customer = CustomerModel(
        id: '',
        userId: userId,
        name: name.trim(),
        phoneNumber: cleanPhone,
        createdAt: DateTime.now(),
      );
      await addCustomer(customer);
    }
  }
}
