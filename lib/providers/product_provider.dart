import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

import 'dart:async';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  StreamSubscription? _productSubscription;

  // Stream active products
  void getProducts() {
    _isLoading = true;
    notifyListeners();

    _productSubscription?.cancel();
    _productSubscription = _productService.getActiveProducts().listen(
      (productData) {
        _products = productData;
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

  // Stream ALL products (for Admin)
  void getAllProducts() {
    _isLoading = true;
    notifyListeners();

    _productSubscription?.cancel();
    _productSubscription = _productService.getAllProducts().listen(
      (productData) {
        _products = productData;
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

  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.addProduct(product);
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

  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.updateProduct(product);
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

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.deleteProduct(productId);
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
    _productSubscription?.cancel();
    super.dispose();
  }
}
