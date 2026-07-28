import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  final String visitId;
  final String shopId;
  final String repId;
  final String routeId;
  final bool visited;
  final String notes;
  final DateTime timestamp;

  VisitModel({
    required this.visitId,
    required this.shopId,
    required this.repId,
    required this.routeId,
    this.visited = true,
    this.notes = '',
    required this.timestamp,
  });

  factory VisitModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        parsedDate = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
      }
    }

    return VisitModel(
      visitId: documentId,
      shopId: map['shopId']?.toString() ?? '',
      repId: map['repId']?.toString() ?? '',
      routeId: map['routeId']?.toString() ?? '',
      visited: map['visited'] ?? true,
      notes: map['notes']?.toString() ?? '',
      timestamp: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'repId': repId,
      'routeId': routeId,
      'visited': visited,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
