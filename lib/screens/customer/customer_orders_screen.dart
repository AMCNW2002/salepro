import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'customer_product_selection_sheet.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<OrderProvider>().getOrdersByShop(user.uid);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const CustomerProductSelectionSheet(),
            ),
          );
        },
        icon: const Icon(Icons.add_shopping_cart, size: 20),
        label: const Text(
          'New Order',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            );
          }

          if (orderProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                orderProvider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final orders = orderProvider.orders;

          return Column(
            children: [
              // Top Bar Header
              Container(
                padding: const EdgeInsets.only(
                  top: 48.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 40.0,
                ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Order History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "New Order" to start shopping!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          8.0,
                          16.0,
                          80.0,
                        ), // Padding for FAB
                        itemCount: orders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final dateStr = DateFormat(
                            'MMM d, yyyy • h:mm a',
                          ).format(order.timestamp);
                          final statusColor = _getStatusColor(order.status);

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: statusColor,
                                    size: 24,
                                  ),
                                ),
                                title: const Text(
                                  'My Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: const Divider(height: 1),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order Details',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...order.items.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text:
                                                          '${item.productName} ',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade800,
                                                        fontSize: 14,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: 'x${item.qty}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Rs. ${(item.price * item.qty).toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
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
          );
        },
      ),
    );
  }
}
