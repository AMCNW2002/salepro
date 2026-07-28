import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../services/shop_service.dart';
import 'dart:async';

class ShopProvider extends ChangeNotifier {
  final ShopService _shopService = ShopService();

  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _shopSubscription;

  List<ShopModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchAllShops() {
    _isLoading = true;
    notifyListeners();
    
    _shopSubscription?.cancel();
    _shopSubscription = _shopService.getAllShops().listen((shopData) {
      _shops = shopData;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void fetchShopsByRoute(String routeId) {
    _isLoading = true;
    notifyListeners();
    
    _shopSubscription?.cancel();
    _shopSubscription = _shopService.getShopsByRoute(routeId).listen((shopData) {
      _shops = shopData;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void fetchUnassignedShops() {
    _isLoading = true;
    notifyListeners();
    
    _shopSubscription?.cancel();
    _shopSubscription = _shopService.getUnassignedShops().listen((shopData) {
      _shops = shopData;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> createShop({
    required String name,
    required String owner,
    required String phone,
    required String address,
    required String routeId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _shopService.createShop(
        name: name,
        owner: owner,
        phone: phone,
        address: address,
        routeId: routeId,
      );
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

  Future<bool> updateShop({
    required String shopId,
    required String name,
    required String owner,
    required String phone,
    required String address,
    required String routeId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _shopService.updateShop(
        shopId: shopId,
        name: name,
        owner: owner,
        phone: phone,
        address: address,
        routeId: routeId,
      );
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

  Future<bool> deleteShop(String shopId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _shopService.deleteShop(shopId);
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
  
  @override
  void dispose() {
    _shopSubscription?.cancel();
    super.dispose();
  }
}
