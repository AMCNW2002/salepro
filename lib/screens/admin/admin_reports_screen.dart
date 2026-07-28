import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/rep_provider.dart';
import '../../../providers/payment_provider.dart';

import 'admin_sales_report_screen.dart';
import 'admin_route_analytics_screen.dart';
import 'admin_rep_analytics_screen.dart';
import 'admin_financial_analytics_screen.dart';
import 'admin_export_center_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getAllProducts();
      context.read<OrderProvider>().fetchAllOrders();
      context.read<ShopProvider>().fetchAllShops();
      context.read<RepProvider>().fetchAllReps();
      context.read<PaymentProvider>().getAllPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMainMenu(),
                const SizedBox(height: 40), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: _buildHeaderTitle(),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a category to view detailed business insights and performance reports.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMainMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;
        return GridView.count(
          crossAxisCount: isDesktop ? 3 : (constraints.maxWidth >= 600 ? 2 : 1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _buildMenuCard(
              'Sales Reports',
              'View total sales, orders, and shop performance.',
              Icons.trending_up,
              Colors.blue,
              const AdminSalesReportScreen(),
            ),
            _buildMenuCard(
              'Route Analytics',
              'Monitor performance across different regions.',
              Icons.map,
              Colors.orange,
              const AdminRouteAnalyticsScreen(),
            ),
            _buildMenuCard(
              'Representative Analytics',
              'Track employee targets, visits, and efficiency.',
              Icons.people,
              Colors.purple,
              const AdminRepAnalyticsScreen(),
            ),
            _buildMenuCard(
              'Financial Reports',
              'Analyze revenue, expenses, and payments.',
              Icons.payments,
              Colors.green,
              const AdminFinancialAnalyticsScreen(),
            ),
            _buildMenuCard(
              'Export Center',
              'Generate PDF and Excel reports for all data.',
              Icons.download_outlined,
              Colors.teal,
              const AdminExportCenterScreen(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget targetScreen,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
