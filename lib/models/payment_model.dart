import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String shopId;
  final String shopName;
  final String repId;
  final String routeId;
  final String routeName;
  final double amount;
  final List<String> relatedOrders;
  final DateTime timestamp;
  final String paymentMethod;

  PaymentModel({
    required this.paymentId,
    required this.shopId,
    this.shopName = '',
    required this.repId,
    required this.routeId,
    this.routeName = '',
    required this.amount,
    this.relatedOrders = const [],
    required this.timestamp,
    this.paymentMethod = 'Cash',
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        parsedDate = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
      }
    }

    return PaymentModel(
      paymentId: documentId,
      shopId: map['shopId']?.toString() ?? '',
      shopName: map['shopName']?.toString() ?? '',
      repId: map['repId']?.toString() ?? '',
      routeId: map['routeId']?.toString() ?? '',
      routeName: map['routeName']?.toString() ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      relatedOrders: List<String>.from(map['relatedOrders'] ?? []),
      timestamp: parsedDate,
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'repId': repId,
      'routeId': routeId,
      'routeName': routeName,
      'amount': amount,
      'relatedOrders': relatedOrders,
      'timestamp': Timestamp.fromDate(timestamp),
      'paymentMethod': paymentMethod,
    };
  }
}
