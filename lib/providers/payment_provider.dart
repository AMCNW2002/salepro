import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  StreamSubscription? _paymentSubscription;

  Future<bool> collectPayment({
    required String shopId,
    required String shopName,
    required String repId,
    required String routeId,
    required String routeName,
    required double amount,
    required String paymentMethod,
    List<String> relatedOrders = const [],
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newPayment = PaymentModel(
        paymentId: FirebaseFirestore.instance.collection('payments').doc().id,
        shopId: shopId,
        shopName: shopName,
        repId: repId,
        routeId: routeId,
        routeName: routeName,
        amount: amount,
        paymentMethod: paymentMethod,
        relatedOrders: relatedOrders,
        timestamp: DateTime.now(),
      );

      await _paymentService.collectPayment(newPayment);

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

  // Get payments by shop
  void getPaymentsByShop(String shopId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _paymentSubscription?.cancel();
    _paymentSubscription = _paymentService.getPaymentsForShop(shopId).listen(
      (paymentData) {
        _payments = paymentData;
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

  // Get payments by rep
  void getPaymentsByRep(String repId) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _paymentSubscription?.cancel();
    _paymentSubscription = _paymentService.getPaymentsForRep(repId).listen(
      (paymentData) {
        _payments = paymentData;
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

  void getAllPayments() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _paymentSubscription?.cancel();
    _paymentSubscription = _paymentService.getAllPayments().listen(
      (paymentData) {
        _payments = paymentData;
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
    _paymentSubscription?.cancel();
    super.dispose();
  }
}
