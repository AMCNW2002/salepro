import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createShop({
    required String name,
    required String owner,
    required String phone,
    required String address,
    required String routeId,
  }) async {
    final docRef = _firestore.collection('shops').doc();
    final shop = ShopModel(
      shopId: docRef.id,
      name: name,
      owner: owner,
      phone: phone,
      address: address,
      routeId: routeId,
    );
    await docRef.set(shop.toMap()).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Connection timeout. Please check your internet connection.');
      },
    );
  }

  Future<void> updateShop({
    required String shopId,
    required String name,
    required String owner,
    required String phone,
    required String address,
    required String routeId,
  }) async {
    await _firestore.collection('shops').doc(shopId).update({
      'name': name,
      'owner': owner,
      'phone': phone,
      'address': address,
      'routeId': routeId,
    });
  }

  Future<void> deleteShop(String shopId) async {
    await _firestore.collection('shops').doc(shopId).delete();
  }

  Stream<List<ShopModel>> getAllShops() {
    return _firestore.collection('shops').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShopModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ShopModel>> getShopsByRoute(String routeId) {
    return _firestore
        .collection('shops')
        .where('routeId', isEqualTo: routeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShopModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
  Stream<List<ShopModel>> getUnassignedShops() {
    return _firestore
        .collection('shops')
        .where('routeId', isEqualTo: '')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShopModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
