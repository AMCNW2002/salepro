import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<PaymentProvider>().getPaymentsByShop(user.uid);
        // Also fetch orders to calculate total due if needed, though usually that's managed backend
        context.read<OrderProvider>().getOrdersByShop(user.uid);
      }
    });
  }

  void _showRecordPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: const Text(
            'To make a payment, please deposit the due amount to our bank account:\n\n'
            'Bank: BOC\n'
            'Account No: 123456789\n'
            'Branch: Colombo\n\n'
            'Please contact your sales representative after making the payment to update the system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PaymentProvider, OrderProvider>(
      builder: (context, paymentProvider, orderProvider, child) {
        if (paymentProvider.isLoading || orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
        }

        final payments = paymentProvider.payments;
        final orders = orderProvider.orders;

        double totalOrdered = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
        double totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);
        double pendingAmount = totalOrdered - totalPaid;
        if (pendingAmount < 0) pendingAmount = 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              // Due Amount Card
              Container(
                padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 32.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pending Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rs. ${pendingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: _showRecordPaymentDialog,
                      icon: const Icon(Icons.account_balance, size: 20),
                      label: const Text('Make a Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (payments.isNotEmpty)
                      Text(
                        '${payments.length} Records',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No payments yet',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 24),
                              ),
                              title: Text(
                                'Rs. ${payment.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937)),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a').format(payment.timestamp),
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.blue.shade100),
                                      ),
                                      child: Text(
                                        payment.paymentMethod,
                                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Collected By',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      payment.repId.substring(0, 5).toUpperCase(),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
