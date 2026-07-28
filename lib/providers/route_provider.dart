import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();

  List<RouteModel> _routes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RouteProvider() {
    _fetchRoutes();
  }

  void _fetchRoutes() {
    _isLoading = true;
    notifyListeners();

    _routeService.getRoutes().listen((routeData) {
      _routes = routeData;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> createRoute({required String name, required String description}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _routeService.createRoute(name: name, description: description);
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

  Future<bool> updateRoute({required String routeId, required String name, required String description}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _routeService.updateRoute(routeId: routeId, name: name, description: description);
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

  Future<bool> deleteRoute(String routeId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _routeService.deleteRoute(routeId);
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
}
