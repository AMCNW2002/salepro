import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';

class RepOrdersScreen extends StatefulWidget {
  const RepOrdersScreen({super.key});

  @override
  State<RepOrdersScreen> createState() => _RepOrdersScreenState();
}

class _RepOrdersScreenState extends State<RepOrdersScreen> {
  String _filter = 'All'; // 'All', 'Today', 'This Week', 'This Month'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<OrderProvider>().getOrdersByRep(user.uid);
      }
    });
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    return orders.where((order) {
      if (_filter == 'All') return true;
      if (_filter == 'Today') {
        return order.timestamp.isAfter(today) ||
            order.timestamp.isAtSameMomentAs(today);
      }
      if (_filter == 'This Week') {
        return order.timestamp.isAfter(startOfWeek) ||
            order.timestamp.isAtSameMomentAs(startOfWeek);
      }
      if (_filter == 'This Month') {
        return order.timestamp.isAfter(startOfMonth) ||
            order.timestamp.isAtSameMomentAs(startOfMonth);
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
            color: const Color(0xFFEF5350).withValues(alpha: 0.3),
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
                'My Orders',
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
                  Icons.shopping_bag_outlined,
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
                            ? const Color(0xFFD32F2F)
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
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredOrders = _getFilteredOrders(
                    orderProvider.orders,
                  );

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found for $_filter.',
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
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final totalItems = order.items.fold<int>(
                        0,
                        (sum, item) => sum + item.qty,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order.shopName.isEmpty
                                        ? 'Order #${order.orderId.substring(0, 8).toUpperCase()}'
                                        : order.shopName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${dateFormat.format(order.timestamp)}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Items: $totalItems product(s)',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ],
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
