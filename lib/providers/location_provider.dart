import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  void startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateLocationInFirestore(null, status: 'offline');
      // Continue anyway, so we can listen to service status changes
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get initial position
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      _updateLocationInFirestore(_currentPosition!, status: 'online');
      notifyListeners();
    } catch(e) {
      print("Error getting initial location: $e");
    }

    // Start listening to stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      )
    ).listen((Position? position) {
      if (position != null) {
        _currentPosition = position;
        _updateLocationInFirestore(position, status: 'online');
        notifyListeners();
      }
    });

    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        _updateLocationInFirestore(_currentPosition, status: 'offline');
      } else if (status == ServiceStatus.enabled) {
        _updateLocationInFirestore(_currentPosition, status: 'online');
      }
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _serviceStatusStream?.cancel();
    _serviceStatusStream = null;
    
    _updateLocationInFirestore(_currentPosition, status: 'offline');
  }

  Future<void> _updateLocationInFirestore(Position? position, {String status = 'online'}) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final Map<String, dynamic> data = {
          'id': user.uid,
          'rep_id': user.uid,
          'last_updated': FieldValue.serverTimestamp(),
          'status': status,
        };
        
        if (position != null) {
          data['latitude'] = position.latitude;
          data['longitude'] = position.longitude;
        }
        
        await _firestore.collection('rep_current_locations').doc(user.uid).set(data, SetOptions(merge: true));
      } catch (e) {
        print("Failed to update location: $e");
      }
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
