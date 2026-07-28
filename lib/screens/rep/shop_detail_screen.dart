import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/shop_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/visit_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/payment_provider.dart';

import 'product_selection_sheet.dart';
import 'payment_collection_sheet.dart';

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().getVisitsByShop(widget.shop.shopId);
      context.read<OrderProvider>().getOrdersByShop(widget.shop.shopId);
      context.read<PaymentProvider>().getPaymentsByShop(widget.shop.shopId);
    });
  }

  void _markVisit() async {
    final userModel = context.read<AuthProvider>().currentUserModel;
    if (userModel == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark this shop as visited?'),
        content: Text('Are you sure you want to mark ${widget.shop.name} as visited?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<VisitProvider>().markVisit(
                shopId: widget.shop.shopId,
                repId: userModel.uid,
                routeId: userModel.routeId,
                notes: 'Routine visit',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Visit marked successfully!' : context.read<VisitProvider>().errorMessage),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _openOrderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ProductSelectionSheet(shop: widget.shop),
    );
  }

  void _openPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PaymentCollectionSheet(shop: widget.shop),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.name),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shop Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Owner: ${widget.shop.owner}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Phone: ${widget.shop.phone}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Address: ${widget.shop.address}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance Due:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs. ${widget.shop.balanceDue.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.shop.balanceDue > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Consumer2<OrderProvider, PaymentProvider>(
                      builder: (context, orderProvider, paymentProvider, child) {
                        final totalOrders = orderProvider.orders.length;
                        final lastOrder = orderProvider.orders.isNotEmpty ? orderProvider.orders.first.timestamp : null;
                        final lastPayment = paymentProvider.payments.isNotEmpty ? paymentProvider.payments.first.timestamp : null;
                        final dateFormat = DateFormat.yMMMd();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Orders: $totalOrders', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Last Order: ${lastOrder != null ? dateFormat.format(lastOrder) : 'N/A'}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Last Payment: ${lastPayment != null ? dateFormat.format(lastPayment) : 'N/A'}', style: const TextStyle(fontSize: 16)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.place),
                    label: const Text('Visit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _markVisit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _openOrderSheet,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _openPaymentSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Last Visit
            const Text(
              'Recent Visits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<VisitProvider>(
              builder: (context, visitProvider, child) {
                if (visitProvider.isLoading) return const Center(child: CircularProgressIndicator());
                if (visitProvider.shopVisits.isEmpty) return const Text('No recent visits.');
                
                final visit = visitProvider.shopVisits.first;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: const Text('Visited'),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(visit.timestamp)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Recent Orders Summary
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
                if (orderProvider.orders.isEmpty) return const Text('No recent orders.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderProvider.orders.length > 3 ? 3 : orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.orange),
                        title: Text('Order #${order.orderId.substring(0, 6)}'),
                        subtitle: Text(DateFormat.yMMMd().format(order.timestamp)),
                        trailing: Text(
                          'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
