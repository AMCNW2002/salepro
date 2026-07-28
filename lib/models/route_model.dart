import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String routeId;
  final String name;
  final String description;
  final DateTime createdAt;

  RouteModel({
    required this.routeId,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      }
    }

    return RouteModel(
      routeId: documentId,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
