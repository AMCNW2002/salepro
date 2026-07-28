import 'package:cloud_firestore/cloud_firestore.dart';

class RepLocationModel {
  final String id;
  final String repId;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final String status;

  RepLocationModel({
    required this.id,
    required this.repId,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.status,
  });

  factory RepLocationModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['last_updated'] != null) {
      if (map['last_updated'] is Timestamp) {
        parsedDate = (map['last_updated'] as Timestamp).toDate();
      } else if (map['last_updated'] is String) {
        parsedDate = DateTime.tryParse(map['last_updated']) ?? DateTime.now();
      }
    }

    return RepLocationModel(
      id: documentId,
      repId: map['rep_id']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: parsedDate,
      status: map['status']?.toString() ?? 'offline',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rep_id': repId,
      'latitude': latitude,
      'longitude': longitude,
      'last_updated': Timestamp.fromDate(lastUpdated),
      'status': status,
    };
  }
}
