import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/visit_model.dart';
import '../services/visit_service.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _visitService = VisitService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<VisitModel> _repVisits = [];
  List<VisitModel> get repVisits => _repVisits;
  StreamSubscription? _repVisitSubscription;

  List<VisitModel> _shopVisits = [];
  List<VisitModel> get shopVisits => _shopVisits;
  StreamSubscription? _shopVisitSubscription;

  // Mark a shop as visited
  Future<bool> markVisit({
    required String shopId,
    required String repId,
    required String routeId,
    String notes = '',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newVisit = VisitModel(
        visitId: '', // Will be assigned by Firestore
        shopId: shopId,
        repId: repId,
        routeId: routeId,
        visited: true,
        notes: notes,
        timestamp: DateTime.now(),
      );

      await _visitService.markVisit(newVisit);

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

  // Get visits by shop
  void getVisitsByShop(String shopId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _shopVisitSubscription?.cancel();
    _shopVisitSubscription = _visitService.getVisitsForShop(shopId).listen(
      (visitData) {
        _shopVisits = visitData;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Get visits by rep
  void getVisitsByRep(String repId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _repVisitSubscription?.cancel();
    _repVisitSubscription = _visitService.getVisitsForRep(repId).listen(
      (visitData) {
        _repVisits = visitData;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _repVisitSubscription?.cancel();
    _shopVisitSubscription?.cancel();
    super.dispose();
  }
}
