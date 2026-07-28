import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _todayVisits = 0;
  int _todayOrders = 0;
  double _todayCollectedPayments = 0.0;
  double _totalPendingPayments = 0.0;
  bool _isLoading = false;

  int get todayVisits => _todayVisits;
  int get todayOrders => _todayOrders;
  double get todayCollectedPayments => _todayCollectedPayments;
  double get totalPendingPayments => _totalPendingPayments;
  bool get isLoading => _isLoading;

  List<double> _todayVisitOrders = [];
  List<double> get todayVisitOrders => _todayVisitOrders;
  
  List<QueryDocumentSnapshot> _todayVisitsDocs = [];
  List<QueryDocumentSnapshot> _todayOrdersDocs = [];

  StreamSubscription? _visitsSub;
  StreamSubscription? _ordersSub;
  StreamSubscription? _paymentsSub;
  StreamSubscription? _shopsSub;
  StreamSubscription? _weeklySalesSub;
  
  List<double> _weeklySales = List.filled(7, 0.0);
  List<double> get weeklySales => _weeklySales;


  void fetchDashboardStats(String repId, String routeId) {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Listen to Today's Visits
    _visitsSub?.cancel();
    _visitsSub = _firestore
        .collection('visits')
        .where('repId', isEqualTo: repId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      _todayVisits = snapshot.docs.length;
      _todayVisitsDocs = snapshot.docs;
      _calculateTodayVisitOrders();
      notifyListeners();
    });

    // Listen to Today's Orders
    _ordersSub?.cancel();
    _ordersSub = _firestore
        .collection('orders')
        .where('repId', isEqualTo: repId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      _todayOrders = snapshot.docs.length;
      _todayOrdersDocs = snapshot.docs;
      _calculateTodayVisitOrders();
      notifyListeners();
    });

    // Listen to Today's Collected Payments
    _paymentsSub?.cancel();
    _paymentsSub = _firestore
        .collection('payments')
        .where('repId', isEqualTo: repId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      _todayCollectedPayments = snapshot.docs.fold(
          0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0).toDouble());
      notifyListeners();
    });

    // Listen to Total Pending Payments for route
    if (routeId.isNotEmpty) {
      _shopsSub?.cancel();
      _shopsSub = _firestore
          .collection('shops')
          .where('routeId', isEqualTo: routeId)
          .snapshots()
          .listen((snapshot) {
        _totalPendingPayments = snapshot.docs.fold(
            0.0, (sum, doc) => sum + (doc.data()['balanceDue'] ?? 0.0).toDouble());
        notifyListeners();
      });
    }

    // Listen to Weekly Sales (last 7 days)
    final startOf7DaysAgo = startOfDay.subtract(const Duration(days: 6));
    _weeklySalesSub?.cancel();
    _weeklySalesSub = _firestore
        .collection('orders')
        .where('repId', isEqualTo: repId)
        .where('timestamp', isGreaterThanOrEqualTo: startOf7DaysAgo)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      final List<double> newWeeklySales = List.filled(7, 0.0);
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? ts = data['timestamp'];
        if (ts != null) {
          final date = ts.toDate();
          // Find which day index this belongs to (0 to 6)
          // Difference in days from startOf7DaysAgo
          final difference = date.difference(startOf7DaysAgo).inDays;
          if (difference >= 0 && difference < 7) {
             final totalAmount = (data['totalAmount'] ?? 0.0).toDouble();
             newWeeklySales[difference] += totalAmount;
          }
        }
      }
      _weeklySales = newWeeklySales;
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _visitsSub?.cancel();
    _ordersSub?.cancel();
    _paymentsSub?.cancel();
    _shopsSub?.cancel();
    _weeklySalesSub?.cancel();
    super.dispose();
  }

  void _calculateTodayVisitOrders() {
    final visits = List<QueryDocumentSnapshot>.from(_todayVisitsDocs);
    visits.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
    
    List<double> visitOrders = [];
    for (var visit in visits) {
      final shopId = visit['shopId'];
      double orderAmount = 0.0;
      for (var order in _todayOrdersDocs) {
        if (order.data() is Map<String, dynamic>) {
          final data = order.data() as Map<String, dynamic>;
          if (data['shopId'] == shopId) {
             orderAmount += (data['totalAmount'] ?? 0.0).toDouble();
          }
        }
      }
      visitOrders.add(orderAmount);
    }
    _todayVisitOrders = visitOrders;
  }
}
