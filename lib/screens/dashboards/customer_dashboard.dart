import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_transition_switcher.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../customer/customer_orders_screen.dart';
import '../customer/customer_payments_screen.dart';
import '../customer/customer_profile_screen.dart';
import '../../services/notification_service.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _CustomerDashboardMain(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const CustomerOrdersScreen(),
      const CustomerPaymentsScreen(),
      const CustomerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: PageTransitionSwitcher(
        index: _currentIndex,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black12,
        indicatorColor: const Color(0xFFD32F2F).withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFFD32F2F)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFFD32F2F)),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFFD32F2F)),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFFD32F2F)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CustomerDashboardMain extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _CustomerDashboardMain({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUserModel;
    
    // Fetch data if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        context.read<OrderProvider>().getOrdersByShop(user.uid);
        context.read<PaymentProvider>().getPaymentsByShop(user.uid);
      }
    });

    return Consumer2<OrderProvider, PaymentProvider>(
      builder: (context, orderProvider, paymentProvider, child) {
        final orders = orderProvider.orders;
        final payments = paymentProvider.payments;

        double totalOrdered = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
        double totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);
        double pendingAmount = totalOrdered - totalPaid;
        if (pendingAmount < 0) pendingAmount = 0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, user, pendingAmount),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2D3E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Total Orders',
                            value: '${orders.length}',
                            icon: Icons.shopping_cart_checkout,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Total Paid',
                            value: 'Rs. ${totalPaid.toStringAsFixed(0)}',
                            icon: Icons.payments_outlined,
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A2D3E),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate(1),
                          child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            
            // Recent Orders List
            orders.isEmpty 
              ? SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No recent orders', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= orders.length || index >= 5) return null; // Show max 5
                        final order = orders[index];
                        final dateStr = DateFormat('MMM d, yyyy').format(order.timestamp);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onTap: () => onNavigate(1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2D3E).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2A2D3E)),
                            ),
                            title: Text(
                              'Order #${order.orderId.substring(0, 6)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(dateStr),
                            trailing: Text(
                              'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2A2D3E),
                              ),
                            ),
                          ),
                        ),
                      );
                      },
                      childCount: orders.length > 5 ? 5 : orders.length,
                    ),
                  ),
                ),
                
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, double pendingAmount) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.shopName.isNotEmpty == true ? user!.shopName : 'My Shop',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (user != null) {
                    _showNotificationsSheet(context, user.uid);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onNavigate(3), // Navigate to Profile tab
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFD32F2F),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Outstanding Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Payment',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rs. ${pendingAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Color(0xFFD32F2F), size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2D3E),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: NotificationService().streamNotifications(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No new notifications'));
                    }
                    
                    final notifications = snapshot.data!;
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notif.isRead ? Colors.grey.shade200 : Colors.red.shade100,
                            child: Icon(
                              Icons.notifications,
                              color: notif.isRead ? Colors.grey : Colors.red,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(notif.body),
                          onTap: () {
                            if (!notif.isRead) {
                              NotificationService().markAsRead(uid, notif.id);
                            }
                          },
                        );
                      },
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
