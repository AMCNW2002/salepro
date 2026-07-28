import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    final batch = _firestore.batch();
    final orderRef = _firestore.collection('orders').doc(order.orderId);

    // Save order
    batch.set(orderRef, order.toMap());

    // Update shop balanceDue
    final shopRef = _firestore.collection('shops').doc(order.shopId);
    batch.update(shopRef, {
      'balanceDue': FieldValue.increment(order.totalAmount),
    });

    // Update product stock and active status
    // We need a transaction or just decrement in batch? 
    // FieldValue.increment works, but we also need to set active to false if it reaches 0.
    // Batch doesn't let us read the value first to conditionally set `active`.
    // It's safer to use a transaction for the entire order creation or just products.
    // Let's use a transaction for the whole process.
  }

  Future<void> createOrderWithTransaction(OrderModel order) async {
    final orderRef = _firestore.collection('orders').doc(order.orderId);
    final shopRef = _firestore.collection('shops').doc(order.shopId);

    await _firestore.runTransaction((transaction) async {
      // 1. Read all product docs to ensure stock is sufficient
      Map<String, DocumentSnapshot> productDocs = {};
      for (var item in order.items) {
        final productRef = _firestore.collection('products').doc(item.productId);
        final doc = await transaction.get(productRef);
        if (!doc.exists) {
          throw Exception("Product ${item.productName} does not exist.");
        }
        productDocs[item.productId] = doc;
      }

      // 2. Perform updates
      transaction.set(orderRef, order.toMap());
      transaction.update(shopRef, {
        'balanceDue': FieldValue.increment(order.totalAmount),
      });

      for (var item in order.items) {
        final doc = productDocs[item.productId]!;
        final currentStock = (doc.data() as Map<String, dynamic>)['stock'] ?? 0;
        final newStock = currentStock - item.qty;
        
        if (newStock < 0) {
          throw Exception("Not enough stock for ${item.productName}. Available: $currentStock");
        }

        bool active = (doc.data() as Map<String, dynamic>)['active'] ?? true;
        if (newStock <= 0) {
          active = false; // Hide product if stock is 0 or less
        }

        transaction.update(doc.reference, {
          'stock': newStock,
          'active': active,
        });
      }
    });
  }

  Stream<List<OrderModel>> getOrdersForShop(String shopId) {
    return _firestore
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return orders;
    });
  }

  Stream<List<OrderModel>> getOrdersForRep(String repId) {
    return _firestore
        .collection('orders')
        .where('repId', isEqualTo: repId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return orders;
    });
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
