import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../models/shop_model.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<String, List<double>> _salesData = {
    'Daily': [], 'Weekly': [], 'Monthly': [],
  };
  Map<String, List<double>> get salesData => _salesData;

  final Map<String, List<double>> _ordersData = {
    'Daily': [], 'Weekly': [], 'Monthly': [],
  };
  Map<String, List<double>> get ordersData => _ordersData;

  final Map<String, Map<String, double>> _paymentsData = {
    'Daily': {}, 'Weekly': {}, 'Monthly': {},
  };
  Map<String, Map<String, double>> get paymentsData => _paymentsData;

  final Map<String, List<String>> _xAxisLabels = {
    'Daily': [], 'Weekly': [], 'Monthly': [],
  };
  Map<String, List<String>> get xAxisLabels => _xAxisLabels;

  // Placeholder for filter states
  DateTimeRange? _selectedDateRange;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  String? _selectedRouteId;
  String? get selectedRouteId => _selectedRouteId;

  String? _selectedRepId;
  String? get selectedRepId => _selectedRepId;

  void setFilters({DateTimeRange? dateRange, String? routeId, String? repId}) {
    _selectedDateRange = dateRange;
    _selectedRouteId = routeId;
    _selectedRepId = repId;
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      
      final dailyStart = now.subtract(const Duration(days: 6));
      final weeklyStart = now.subtract(const Duration(days: 27)); 
      final monthlyStart = DateTime(now.year - 1, now.month + 1, 1); 

      _initializeDailyData(now);
      _initializeWeeklyData(now);
      _initializeMonthlyData(now);

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: monthlyStart)
          .get();

      final allOrders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('timestamp', isGreaterThanOrEqualTo: monthlyStart)
          .get();

      final allPayments = paymentsSnapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();

      final shopsSnapshot = await _firestore.collection('shops').get();
      final allShops = shopsSnapshot.docs
          .map((doc) => ShopModel.fromMap(doc.data(), doc.id))
          .toList();
      
      double totalPendingBalance = 0;
      for (var shop in allShops) {
        if (shop.balanceDue > 0) totalPendingBalance += shop.balanceDue;
      }

      // Process Daily Data (Last 7 Days)
      double totalPaymentsDaily = 0;
      for (var order in allOrders.where((o) => o.timestamp.isAfter(dailyStart) || isSameDay(o.timestamp, dailyStart))) {
        String label = DateFormat('E').format(order.timestamp);
        int index = _xAxisLabels['Daily']!.indexOf(label);
        if (index != -1) {
          _salesData['Daily']![index] += order.totalAmount;
          _ordersData['Daily']![index] += 1;
        }
      }
      for (var payment in allPayments.where((p) => p.timestamp.isAfter(dailyStart) || isSameDay(p.timestamp, dailyStart))) {
        totalPaymentsDaily += payment.amount;
      }
      _paymentsData['Daily']!['Received'] = totalPaymentsDaily;
      _paymentsData['Daily']!['Pending'] = totalPendingBalance;

      // Process Weekly Data (Last 4 Weeks)
      double totalPaymentsWeekly = 0;
      for (var order in allOrders.where((o) => o.timestamp.isAfter(weeklyStart) || isSameDay(o.timestamp, weeklyStart))) {
        int weekIndex = _getWeekIndex(order.timestamp, now);
        if (weekIndex >= 0 && weekIndex < 4) {
           int arrayIndex = 3 - weekIndex;
          _salesData['Weekly']![arrayIndex] += order.totalAmount;
          _ordersData['Weekly']![arrayIndex] += 1;
        }
      }
      for (var payment in allPayments.where((p) => p.timestamp.isAfter(weeklyStart) || isSameDay(p.timestamp, weeklyStart))) {
        totalPaymentsWeekly += payment.amount;
      }
      _paymentsData['Weekly']!['Received'] = totalPaymentsWeekly;
      _paymentsData['Weekly']!['Pending'] = totalPendingBalance;

      // Process Monthly Data (Last 12 Months)
      double totalPaymentsMonthly = 0;
      for (var order in allOrders) {
         String label = DateFormat('MMM').format(order.timestamp);
         int index = _xAxisLabels['Monthly']!.indexOf(label);
         if (index != -1) {
            _salesData['Monthly']![index] += order.totalAmount;
            _ordersData['Monthly']![index] += 1;
         }
      }
      for (var payment in allPayments) {
        totalPaymentsMonthly += payment.amount;
      }
      _paymentsData['Monthly']!['Received'] = totalPaymentsMonthly;
      _paymentsData['Monthly']!['Pending'] = totalPendingBalance;

    } catch (e) {
      debugPrint('Error fetching report data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _getWeekIndex(DateTime target, DateTime now) {
    final difference = now.difference(target).inDays;
    return difference ~/ 7;
  }

  void _initializeDailyData(DateTime now) {
    _xAxisLabels['Daily'] = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date);
    });
    _salesData['Daily'] = List.filled(7, 0.0);
    _ordersData['Daily'] = List.filled(7, 0.0);
  }

  void _initializeWeeklyData(DateTime now) {
    _xAxisLabels['Weekly'] = ['Week 4', 'Week 3', 'Week 2', 'This Wk'];
    _salesData['Weekly'] = List.filled(4, 0.0);
    _ordersData['Weekly'] = List.filled(4, 0.0);
  }

  void _initializeMonthlyData(DateTime now) {
    _xAxisLabels['Monthly'] = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - 11 + i, 1);
      return DateFormat('MMM').format(date);
    });
    _salesData['Monthly'] = List.filled(12, 0.0);
    _ordersData['Monthly'] = List.filled(12, 0.0);
  }
}
