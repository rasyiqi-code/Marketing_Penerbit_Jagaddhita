import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class ProductService extends BaseFirestoreService {
  ProductService({super.firestore});
  // Product Catalog
  Stream<List<ProductModel>> getProducts(int houseType) {
    return db
        .collection('products')
        .where('house_type', isEqualTo: houseType)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addProduct(ProductModel product) {
    return db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) {
    return db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) {
    return db.collection('products').doc(productId).delete();
  }

  // Global Settings
  Stream<GlobalSettingsModel> getGlobalSettings() {
    return db.collection('global_settings').doc('config').snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return GlobalSettingsModel.fromMap(doc.data()!);
      } else {
        return GlobalSettingsModel(
          bonusPercentR1: 0,
          minPayout: 5000000,
          latestInfo: 'Batas klaim pulsa bulan ini: Tgl 25.',
        );
      }
    });
  }

  Future<void> updateGlobalSettings(GlobalSettingsModel settings) {
    return db
        .collection('global_settings')
        .doc('config')
        .set(settings.toMap());
  }
}
