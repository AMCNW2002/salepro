import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/payment_model.dart';

class RepPaymentsScreen extends StatefulWidget {
  const RepPaymentsScreen({super.key});

  @override
  State<RepPaymentsScreen> createState() => _RepPaymentsScreenState();
}

class _RepPaymentsScreenState extends State<RepPaymentsScreen> {
  String _filter = 'All'; // 'All', 'Today', 'This Week', 'This Month'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<PaymentProvider>().getPaymentsByRep(user.uid);
      }
    });
  }

  List<PaymentModel> _getFilteredPayments(List<PaymentModel> payments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    return payments.where((payment) {
      if (_filter == 'All') return true;
      if (_filter == 'Today') {
        return payment.timestamp.isAfter(today) ||
            payment.timestamp.isAtSameMomentAs(today);
      }
      if (_filter == 'This Week') {
        return payment.timestamp.isAfter(startOfWeek) ||
            payment.timestamp.isAtSameMomentAs(startOfWeek);
      }
      if (_filter == 'This Month') {
        return payment.timestamp.isAfter(startOfMonth) ||
            payment.timestamp.isAtSameMomentAs(startOfMonth);
      }
      return true;
    }).toList();
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Payments',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Today', 'This Week', 'This Month'].map((
                filter,
              ) {
                final isSelected = _filter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _filter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF15803D)
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: Consumer<PaymentProvider>(
                builder: (context, paymentProvider, child) {
                  if (paymentProvider.isLoading &&
                      paymentProvider.payments.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredPayments = _getFilteredPayments(
                    paymentProvider.payments,
                  );

                  if (filteredPayments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payments found for $_filter.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.payments,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.shopName.isEmpty
                                          ? 'Receipt #${payment.paymentId.substring(0, 8).toUpperCase()}'
                                          : payment.shopName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(payment.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rs. ${payment.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
