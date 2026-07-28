import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'product_provider.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  StreamSubscription? _orderSubscription;

  double calculateTotal(List<OrderItemModel> items) {
    double total = 0.0;
    for (var item in items) {
      total += (item.price * item.qty);
    }
    return total;
  }

  Future<bool> createOrder({
    required String shopId,
    required String shopName,
    required String repId,
    required String routeId,
    required List<OrderItemModel> items,
    required ProductProvider productProvider,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final totalAmount = calculateTotal(items);

      final newOrder = OrderModel(
        orderId: FirebaseFirestore.instance.collection('orders').doc().id, // Generate ID
        shopId: shopId,
        shopName: shopName,
        repId: repId,
        routeId: routeId,
        items: items,
        totalAmount: totalAmount,
        status: 'confirmed',
        timestamp: DateTime.now(),
      );

      await _orderService.createOrderWithTransaction(newOrder);

      // productProvider stock logic is now handled in the backend transaction via OrderService.
      // But we may want to tell the ProductProvider to refresh if it's using one-time fetch.
      // Since we changed ProductProvider to use streams, it will auto-update!

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

  // Get orders by shop
  void getOrdersByShop(String shopId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _orderSubscription?.cancel();
    _orderSubscription = _orderService.getOrdersForShop(shopId).listen(
      (orderData) {
        _orders = orderData;
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

  // Get orders by rep
  void getOrdersByRep(String repId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _orderSubscription?.cancel();
    _orderSubscription = _orderService.getOrdersForRep(repId).listen(
      (orderData) {
        _orders = orderData;
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

  void fetchAllOrders() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _orderSubscription?.cancel();
    _orderSubscription = _orderService.getAllOrders().listen(
      (orderData) {
        _orders = orderData;
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
    _orderSubscription?.cancel();
    super.dispose();
  }
}
