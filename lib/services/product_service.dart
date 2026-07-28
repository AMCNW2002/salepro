import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream all active products for real-time updates
  Stream<List<ProductModel>> getActiveProducts() {
    return _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream ALL products (for admin)
  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.productId)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    // Usually it's better to soft delete by setting active to false
    await _firestore.collection('products').doc(productId).update({
      'active': false,
    });
  }
}
