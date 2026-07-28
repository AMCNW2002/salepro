import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).add(data);
  }

  Future<void> setDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }

  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(String collectionPath) async {
    return await _firestore.collection(collectionPath).get();
  }
}
