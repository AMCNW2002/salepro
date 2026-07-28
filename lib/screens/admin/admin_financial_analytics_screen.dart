import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/route_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/rep_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/route_model.dart';
import '../../../models/user_model.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_model.dart';
import '../../../models/shop_model.dart';

class AdminFinancialAnalyticsScreen extends StatefulWidget {
  const AdminFinancialAnalyticsScreen({super.key});

  @override
  State<AdminFinancialAnalyticsScreen> createState() =>
      _AdminFinancialAnalyticsScreenState();
}

class _AdminFinancialAnalyticsScreenState
    extends State<AdminFinancialAnalyticsScreen> {
  String _selectedFinancialPeriod = 'This Month';
  String _selectedFinancialRoute = 'All';
  String _selectedFinancialRep = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinancialAnalytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFinancialAnalyticsSection(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAnalyticsSection() {
    final orders = context.watch<OrderProvider>().orders;
    final payments = context.watch<PaymentProvider>().payments;
    final routes = context.watch<RouteProvider>().routes;
    final reps = context.watch<RepProvider>().reps;
    final shops = context.watch<ShopProvider>().shops;

    DateTime now = DateTime.now();
    DateTime startDate = DateTime(2000);
    DateTime endDate = DateTime(now.year + 10);
    DateTime currentMonthStart = DateTime(now.year, now.month, 1);
    DateTime previousMonthStart = DateTime(now.year, now.month - 1, 1);
    DateTime previousMonthEnd = DateTime(now.year, now.month, 0);

    if (_selectedFinancialPeriod == 'This Month') {
      startDate = currentMonthStart;
    } else if (_selectedFinancialPeriod == 'Last Month') {
      startDate = previousMonthStart;
      endDate = previousMonthEnd;
    } else if (_selectedFinancialPeriod == 'This Year') {
      startDate = DateTime(now.year, 1, 1);
    }

    List<OrderModel> filteredOrders = orders.where((o) {
      bool matchesDate =
          o.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          o.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
      bool matchesRoute =
          _selectedFinancialRoute == 'All' ||
          o.routeId == _selectedFinancialRoute;
      bool matchesRep =
          _selectedFinancialRep == 'All' || o.repId == _selectedFinancialRep;
      return matchesDate && matchesRoute && matchesRep;
    }).toList();

    List<PaymentModel> filteredPayments = payments.where((p) {
      bool matchesDate =
          p.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          p.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
      bool matchesRoute =
          _selectedFinancialRoute == 'All' ||
          p.routeId == _selectedFinancialRoute;
      bool matchesRep =
          _selectedFinancialRep == 'All' || p.repId == _selectedFinancialRep;
      return matchesDate && matchesRoute && matchesRep;
    }).toList();

    double totalRevenue = filteredOrders
        .where((o) => o.status != 'cancelled')
        .fold(0.0, (acc, val) => acc + val.totalAmount);
    double totalCollected = filteredPayments.fold(
      0.0,
      (acc, val) => acc + val.amount,
    );

    double totalIncome = totalRevenue; // Simplified
    double totalExpenses = 0.0;
    double netProfit = totalIncome - totalExpenses;
    double profitPct = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor business income, revenue performance, payments, and financial activities.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        _buildFinancialFilters(routes, reps),
        const SizedBox(height: 24),

        _buildSleekFinancialKPIs(
          totalRevenue,
          totalCollected,
          totalIncome,
          netProfit,
          profitPct,
        ),
        const SizedBox(height: 32),

        _buildModernIncomeExpense(
          totalIncome,
          totalExpenses,
          netProfit,
          profitPct,
        ),
        const SizedBox(height: 32),

        LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth >= 900;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRecentTransactionsList(
                      filteredOrders.take(5).toList(),
                      payments,
                      reps,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildOutstandingDebtsList(
                      shops.take(5).toList(),
                      routes,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildRecentTransactionsList(
                    filteredOrders.take(5).toList(),
                    payments,
                    reps,
                  ),
                  const SizedBox(height: 24),
                  _buildOutstandingDebtsList(shops.take(5).toList(), routes),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSleekFinancialKPIs(
    double totalRev,
    double totalCollected,
    double income,
    double profit,
    double profitPct,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;
        return GridView.count(
          crossAxisCount: isDesktop ? 4 : (constraints.maxWidth >= 600 ? 2 : 1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 2.0 : 2.6,
          children: [
            _buildSleekMetricCard(
              'Gross Revenue',
              'Rs. ${totalRev.toStringAsFixed(0)}',
              Icons.monetization_on,
              [Colors.blue.shade300, Colors.blue.shade400],
            ),
            _buildSleekMetricCard(
              'Total Collected',
              'Rs. ${totalCollected.toStringAsFixed(0)}',
              Icons.payments,
              [Colors.green.shade300, Colors.green.shade400],
            ),
            _buildSleekMetricCard(
              'Pending',
              'Rs. ${(totalRev - totalCollected > 0 ? totalRev - totalCollected : 0).toStringAsFixed(0)}',
              Icons.receipt_long,
              [Colors.orange.shade300, Colors.orange.shade400],
            ),
            _buildSleekMetricCard(
              'Net Profit Margin',
              '${profitPct.toStringAsFixed(1)}%',
              Icons.pie_chart,
              [Colors.purple.shade300, Colors.purple.shade400],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernIncomeExpense(
    double income,
    double expenses,
    double profit,
    double profitPct,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income vs Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Income',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rs. ${income.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Expenses',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        'Rs. ${expenses.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Net Profit',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rs. ${profit.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: income > 0 ? (income * 100).toInt() : 1,
                  child: Container(height: 12, color: Colors.green),
                ),
                Expanded(
                  flex: expenses > 0
                      ? (expenses * 100).toInt()
                      : (income == 0 ? 1 : 0),
                  child: Container(height: 12, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList(
    List<OrderModel> orders,
    List<PaymentModel> payments,
    List<UserModel> reps,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFFC62828)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Text('No recent transactions.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final o = orders[index];
                final rep = reps
                    .firstWhere(
                      (r) => r.uid == o.repId,
                      orElse: () => UserModel(
                        uid: '',
                        name: 'Unknown',
                        email: '',
                        phone: '',
                        createdAt: DateTime.now(),
                      ),
                    )
                    .name;

                double paid = payments
                    .where((p) => p.relatedOrders.contains(o.orderId))
                    .fold(0.0, (acc, val) => acc + val.amount);
                bool isPaid = paid >= o.totalAmount;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isPaid
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      isPaid ? Icons.check : Icons.access_time,
                      color: isPaid ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    o.shopName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Rep: $rep • INV-${o.orderId.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${o.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isPaid ? 'Paid' : 'Pending',
                        style: TextStyle(
                          color: isPaid ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOutstandingDebtsList(
    List<ShopModel> shops,
    List<RouteModel> routes,
  ) {
    var shopsWithDebt = shops.where((s) => s.balanceDue > 0).toList();
    shopsWithDebt.sort((a, b) => b.balanceDue.compareTo(a.balanceDue));
    var topDebtors = shopsWithDebt.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Top Outstanding Debts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFFC62828)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topDebtors.isEmpty)
            const Text('No outstanding debts.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topDebtors.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final s = topDebtors[index];
                final routeName = routes
                    .firstWhere(
                      (r) => r.routeId == s.routeId,
                      orElse: () => RouteModel(
                        routeId: '',
                        name: 'Unknown',
                        createdAt: DateTime.now(),
                      ),
                    )
                    .name;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Route: $routeName',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    'Rs. ${s.balanceDue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialFilters(List<RouteModel> routes, List<UserModel> reps) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 150,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFinancialPeriod,
              items: [
                'All Time',
                'This Year',
                'This Month',
                'Last Month',
              ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedFinancialPeriod = val);
              },
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFinancialRoute,
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Routes')),
                ...routes.map(
                  (r) =>
                      DropdownMenuItem(value: r.routeId, child: Text(r.name)),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFinancialRoute = val);
              },
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFinancialRep,
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Reps')),
                ...reps.map(
                  (r) => DropdownMenuItem(value: r.uid, child: Text(r.name)),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFinancialRep = val);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFinancialPeriod = 'This Month';
                _selectedFinancialRoute = 'All';
                _selectedFinancialRep = 'All';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekMetricCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
