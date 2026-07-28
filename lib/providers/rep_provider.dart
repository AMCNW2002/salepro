import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/rep_location_model.dart';
import '../services/rep_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class RepProvider extends ChangeNotifier {
  final RepService _repService = RepService();

  List<UserModel> _reps = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _repSubscription;

  List<UserModel> get reps => _reps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchAllReps() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    _repSubscription?.cancel();
    _repSubscription = _repService.getAllReps().listen((repData) {
      _reps = repData;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Stream<List<RepLocationModel>> getRepLocationsStream() {
    return _repService.getRepLocationsStream();
  }

  Future<bool> assignRouteToRep(String repId, String routeId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repService.assignRouteToRep(repId, routeId);
      
      // Send notifications to all customers in the route
      try {
        final rep = _reps.firstWhere((r) => r.uid == repId);
        
        final shopsSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .where('routeId', isEqualTo: routeId)
            .get();
            
        for (var shopDoc in shopsSnapshot.docs) {
          final customerUid = shopDoc.id;
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(customerUid).get();
          if (userDoc.exists) {
            await NotificationService().saveNotification(
              customerUid,
              'Rep Assigned for Today!',
              'Rep ${rep.name} will visit your shop today. Contact: ${rep.phone}',
            );
          }
        }
      } catch (e) {
        print('Error sending notifications: $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordVisit({
    required String shopId,
    required String repId,
    required String routeId,
  }) async {
    try {
      await _repService.recordVisit(
        shopId: shopId,
        repId: repId,
        routeId: routeId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _repSubscription?.cancel();
    super.dispose();
  }
}
