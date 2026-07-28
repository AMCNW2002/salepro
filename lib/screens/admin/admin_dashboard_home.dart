import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_dashboard_provider.dart';
import 'admin_reps_screen.dart';
import 'admin_stock_alert_screen.dart';
import 'admin_rep_location_screen.dart';

class AdminDashboardHome extends StatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  State<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends State<AdminDashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardProvider>().fetchDashboardData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUserModel?.name ?? "Admin",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today: ${auth.currentUserModel?.shopName ?? "SalePro"} | $today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dashboard summary cards
            if (dashboard.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTopStatCard(
                      title: "Today's Orders",
                      value: dashboard.todaysOrders.toString(),
                      icon: Icons.shopping_cart_outlined,
                      color: const Color(0xFF2563EB), // Blue
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTopStatCard(
                      title: "Today's Sales",
                      value: 'Rs. ${dashboard.todaysSales.toStringAsFixed(2)}',
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF059669), // Green
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTopStatCard(
                      title: 'Collected',
                      value: 'Rs. ${dashboard.todaysPayments.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF7C3AED), // Purple
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTopStatCard(
                      title: 'Pending',
                      value: 'Rs. ${dashboard.pendingPayments.toStringAsFixed(2)}',
                      icon: Icons.pending_actions_outlined,
                      color: const Color(0xFFEA580C), // Orange
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Additional Cards
              Text(
                'Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildGridCard(
                    context,
                    'Total Shops',
                    dashboard.totalShops.toString(),
                    Icons.store_mall_directory_outlined,
                    [const Color(0xFF4F46E5), const Color(0xFF818CF8)], // Indigo
                    null,
                  ),
                  _buildGridCard(
                    context,
                    'Sales Reps',
                    dashboard.totalReps.toString(),
                    Icons.people_outline,
                    [const Color(0xFF059669), const Color(0xFF34D399)], // Emerald
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRepsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    'Active Routes',
                    dashboard.activeRoutes.toString(),
                    Icons.map_outlined,
                    [const Color(0xFFD97706), const Color(0xFFFBBF24)], // Amber
                    null,
                  ),
                  _buildGridCard(
                    context,
                    'Low Stock',
                    dashboard.lowStockProducts.toString(),
                    Icons.inventory_2_outlined,
                    [const Color(0xFFDC2626), const Color(0xFFF87171)], // Red
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminStockAlertScreen(),
                        ),
                      );
                    },
                    isAlert: dashboard.lowStockProducts > 0,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the exact width and height of a single GridView card
                  final cardWidth = (constraints.maxWidth - 16) / 2;
                  final cardHeight = cardWidth / 1.1; // childAspectRatio is 1.1

                  return Center(
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildGridCard(
                        context,
                        'Rep Locations',
                        'Track',
                        Icons.location_on_outlined,
                        [const Color(0xFF2563EB), const Color(0xFF60A5FA)], // Blue
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRepLocationScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback? onTap, {
    bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAlert)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
