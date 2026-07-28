import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _todaysOrders = 0;
  int get todaysOrders => _todaysOrders;

  double _todaysSales = 0.0;
  double get todaysSales => _todaysSales;

  double _todaysPayments = 0.0;
  double get todaysPayments => _todaysPayments;

  double _pendingPayments = 0.0;
  double get pendingPayments => _pendingPayments;

  int _totalShops = 0;
  int get totalShops => _totalShops;

  int _totalReps = 0;
  int get totalReps => _totalReps;

  int _activeRoutes = 0;
  int get activeRoutes => _activeRoutes;

  int _lowStockProducts = 0;
  int get lowStockProducts => _lowStockProducts;

  StreamSubscription? _ordersSub;
  StreamSubscription? _paymentsSub;
  StreamSubscription? _shopsSub;
  StreamSubscription? _usersSub;
  StreamSubscription? _routesSub;
  StreamSubscription? _productsSub;

  void fetchDashboardData() {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Listen to Today's Orders
    _ordersSub?.cancel();
    _ordersSub = _firestore
        .collection('orders')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      _todaysOrders = snapshot.docs.length;
      _todaysSales = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['totalAmount'] ?? 0.0).toDouble();
      });
      notifyListeners();
    });

    // Listen to Today's Payments
    _paymentsSub?.cancel();
    _paymentsSub = _firestore
        .collection('payments')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      _todaysPayments = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['amount'] ?? 0.0).toDouble();
      });
      notifyListeners();
    });

    // Listen to Shops (Count and Pending Payments)
    _shopsSub?.cancel();
    _shopsSub = _firestore.collection('shops').snapshots().listen((snapshot) {
      _totalShops = snapshot.docs.length;
      _pendingPayments = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['balanceDue'] ?? 0.0).toDouble();
      });
      notifyListeners();
    });

    // Listen to Total Reps and Active Routes (Day to day use)
    _usersSub?.cancel();
    _usersSub = _firestore
        .collection('users')
        .where('role', isEqualTo: 'rep')
        .snapshots()
        .listen((snapshot) {
      _totalReps = snapshot.docs.length;
      
      // Calculate real active routes (assigned to reps today)
      final activeRouteIds = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final routeId = data['routeId'] as String?;
        if (routeId != null && routeId.isNotEmpty) {
          activeRouteIds.add(routeId);
        }
      }
      _activeRoutes = activeRouteIds.length;
      
      notifyListeners();
    });

    // Listen to Low Stock Products
    _productsSub?.cancel();
    _productsSub = _firestore
        .collection('products')
        // We can't query where stock <= minStock directly in firestore unless minStock is constant. 
        // We will fetch all active products and filter locally for low stock.
        .where('active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _lowStockProducts = snapshot.docs.where((doc) {
        final stock = doc.data()['stock'] ?? 0;
        final minStock = doc.data()['minStock'] ?? 5;
        return stock <= minStock;
      }).length;
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _paymentsSub?.cancel();
    _shopsSub?.cancel();
    _usersSub?.cancel();
    _routesSub?.cancel();
    _productsSub?.cancel();
    super.dispose();
  }
}
