import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String shopName;
  final String shopAddress;
  final String role;
  final String routeId;
  final DateTime? routeUpdatedAt;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.shopName = '',
    this.shopAddress = '',
    this.role = 'customer',
    this.routeId = '',
    this.routeUpdatedAt,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      }
    }

    DateTime? parsedRouteUpdated;
    if (map['routeUpdatedAt'] != null) {
      if (map['routeUpdatedAt'] is Timestamp) {
        parsedRouteUpdated = (map['routeUpdatedAt'] as Timestamp).toDate();
      } else if (map['routeUpdatedAt'] is String) {
        parsedRouteUpdated = DateTime.tryParse(map['routeUpdatedAt']);
      }
    }

    DateTime? parsedLastLocationUpdate;
    if (map['lastLocationUpdate'] != null) {
      if (map['lastLocationUpdate'] is Timestamp) {
        parsedLastLocationUpdate = (map['lastLocationUpdate'] as Timestamp).toDate();
      } else if (map['lastLocationUpdate'] is String) {
        parsedLastLocationUpdate = DateTime.tryParse(map['lastLocationUpdate']);
      }
    }

    return UserModel(
      uid: documentId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      shopName: map['shopName']?.toString() ?? '',
      shopAddress: map['shopAddress']?.toString() ?? '',
      role: map['role']?.toString() ?? 'customer',
      routeId: map['routeId']?.toString() ?? '',
      routeUpdatedAt: parsedRouteUpdated,
      createdAt: parsedDate,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastLocationUpdate: parsedLastLocationUpdate,
      fcmToken: map['fcmToken']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'role': role,
      'routeId': routeId,
      'routeUpdatedAt': routeUpdatedAt != null ? Timestamp.fromDate(routeUpdatedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'latitude': latitude,
      'longitude': longitude,
      'lastLocationUpdate': lastLocationUpdate != null ? Timestamp.fromDate(lastLocationUpdate!) : null,
      'fcmToken': fcmToken,
    };
  }
}
