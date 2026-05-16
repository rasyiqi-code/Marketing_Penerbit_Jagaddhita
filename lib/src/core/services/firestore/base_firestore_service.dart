import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreService {
  final FirebaseFirestore db;

  BaseFirestoreService({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;
}
