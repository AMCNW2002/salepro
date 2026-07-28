import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final int qty;
  final double price;
  final double subtotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      qty: map['qty']?.toInt() ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String orderId;
  final String shopId;
  final String shopName;
  final String repId;
  final String routeId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // "pending" | "confirmed"
  final DateTime timestamp;

  OrderModel({
    required this.orderId,
    required this.shopId,
    this.shopName = '',
    required this.repId,
    required this.routeId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    required this.timestamp,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        parsedDate = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
      }
    }

    return OrderModel(
      orderId: documentId,
      shopId: map['shopId']?.toString() ?? '',
      shopName: map['shopName']?.toString() ?? '',
      repId: map['repId']?.toString() ?? '',
      routeId: map['routeId']?.toString() ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status']?.toString() ?? 'pending',
      timestamp: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'repId': repId,
      'routeId': routeId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
