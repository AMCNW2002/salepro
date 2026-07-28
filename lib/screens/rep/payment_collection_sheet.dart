import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/shop_model.dart';
import '../../../models/route_model.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/route_provider.dart';

class PaymentCollectionSheet extends StatefulWidget {
  final ShopModel shop;

  const PaymentCollectionSheet({super.key, required this.shop});

  @override
  State<PaymentCollectionSheet> createState() => _PaymentCollectionSheetState();
}

class _PaymentCollectionSheetState extends State<PaymentCollectionSheet> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Cheque', 'Bank Transfer'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _collectPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }

    if (amount > widget.shop.balanceDue && widget.shop.balanceDue > 0) {
      // Optional: Add warning or allow overpayment
      // For now, let's just proceed
    }

    final userModel = context.read<AuthProvider>().currentUserModel;
    if (userModel == null) return;

    final routeName = context.read<RouteProvider>().routes.firstWhere(
      (r) => r.routeId == userModel.routeId,
      orElse: () => RouteModel(routeId: '', name: userModel.routeId, createdAt: DateTime.now()),
    ).name;

    final paymentProvider = context.read<PaymentProvider>();
    final success = await paymentProvider.collectPayment(
      shopId: widget.shop.shopId,
      shopName: widget.shop.name,
      repId: userModel.uid,
      routeId: userModel.routeId,
      routeName: routeName,
      amount: amount,
      paymentMethod: _selectedPaymentMethod,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment collected successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentProvider.errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the keyboard automatically when sheet opens
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Collect Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey.shade100,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Outstanding Balance:', style: TextStyle(fontSize: 16)),
                  Text(
                    'Rs. ${widget.shop.balanceDue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.shop.balanceDue > 0 ? Colors.red.shade800 : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Amount to collect',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade800, width: 2),
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _paymentMethods.map((method) {
              return ChoiceChip(
                label: Text(method),
                selected: _selectedPaymentMethod == method,
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: _selectedPaymentMethod == method ? Colors.white : Colors.black,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: context.watch<PaymentProvider>().isLoading ? null : _collectPayment,
            icon: context.watch<PaymentProvider>().isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.check_circle_outline),
            label: const Text('Confirm Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
