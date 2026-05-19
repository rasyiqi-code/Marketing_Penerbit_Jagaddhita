import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/base_firestore_service.dart';

class LinkBioService extends BaseFirestoreService {
  LinkBioService({super.firestore});
  Stream<List<LinkBioModel>> getLinks(String userId) {
    return db
        .collection('links')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LinkBioModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addLink(LinkBioModel link) {
    return db.collection('links').add(link.toJson());
  }

  Future<void> updateLink(LinkBioModel link) {
    return db.collection('links').doc(link.id).update(link.toJson());
  }

  Future<void> deleteLink(String linkId) {
    return db.collection('links').doc(linkId).delete();
  }
}
