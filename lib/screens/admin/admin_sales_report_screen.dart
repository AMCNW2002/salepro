import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';

class AdminSalesReportScreen extends StatelessWidget {
  const AdminSalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SalesReport'),
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
                _buildSalesReportsSection(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReportsSection() {
    return Consumer2<ProductProvider, OrderProvider>(
      builder: (context, productProvider, orderProvider, child) {
        final orders = orderProvider.orders;
        final products = productProvider.products;

        double totalSales = 0.0;
        int completedSalesCount = 0;
        int totalProductsSold = 0;
        Map<String, double> productRevenue = {};
        Map<String, int> productQtySold = {};

        final now = DateTime.now();
        double currentMonthSales = 0.0;
        double previousMonthSales = 0.0;

        for (var order in orders) {
          if (order.status.toLowerCase() != 'cancelled' &&
              order.status.toLowerCase() != 'pending') {
            totalSales += order.totalAmount;
            completedSalesCount++;

            if (order.timestamp.year == now.year &&
                order.timestamp.month == now.month) {
              currentMonthSales += order.totalAmount;
            } else if (order.timestamp.year ==
                    (now.month == 1 ? now.year - 1 : now.year) &&
                order.timestamp.month ==
                    (now.month == 1 ? 12 : now.month - 1)) {
              previousMonthSales += order.totalAmount;
            }

            for (var item in order.items) {
              totalProductsSold += item.qty;
              productRevenue[item.productId] =
                  (productRevenue[item.productId] ?? 0.0) + item.subtotal;
              productQtySold[item.productId] =
                  (productQtySold[item.productId] ?? 0) + item.qty;
            }
          }
        }

        double salesGrowth = previousMonthSales > 0
            ? ((currentMonthSales - previousMonthSales) / previousMonthSales) *
                  100
            : (currentMonthSales > 0 ? 100.0 : 0.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Intelligence',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive dashboard for revenue and product performance.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              _buildCreativeSalesSummary(
                totalSales,
                completedSalesCount,
                totalProductsSold,
                salesGrowth,
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
                          flex: 3,
                          child: _buildCreativeSalesTrend(
                            orders,
                            currentMonthSales,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildCreativeTopProducts(
                            products,
                            productRevenue,
                            productQtySold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCreativeSalesTrend(orders, currentMonthSales),
                        const SizedBox(height: 24),
                        _buildCreativeTopProducts(
                          products,
                          productRevenue,
                          productQtySold,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreativeSalesSummary(
    double totalSales,
    int orders,
    int products,
    double growth,
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
          childAspectRatio: isDesktop ? 1.6 : 2.0,
          children: [
            _buildSleekMetricCard(
              'Gross Revenue',
              'Rs. ${totalSales.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              [Color(0xFF4776E6), Color(0xFF8E54E9)],
            ),
            _buildSleekMetricCard(
              'Total Orders',
              orders.toString(),
              Icons.shopping_bag,
              [Color(0xFFFF512F), Color(0xFFDD2476)],
            ),
            _buildSleekMetricCard(
              'Products Sold',
              products.toString(),
              Icons.category,
              [Color(0xFF11998e), Color(0xFF38ef7d)],
            ),
            _buildSleekMetricCard(
              'MoM Growth',
              '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
              growth >= 0 ? Icons.trending_up : Icons.trending_down,
              [Color(0xFFF2994A), Color(0xFFF2C94C)],
            ),
          ],
        );
      },
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

  Widget _buildCreativeSalesTrend(
    List<dynamic> orders,
    double currentMonthSales,
  ) {
    final now = DateTime.now();
    List<double> weeklySales = [0.0, 0.0, 0.0, 0.0, 0.0];

    for (var order in orders) {
      if (order.status.toLowerCase() != 'cancelled' &&
          order.status.toLowerCase() != 'pending') {
        if (order.timestamp.year == now.year &&
            order.timestamp.month == now.month) {
          int day = order.timestamp.day;
          if (day <= 7)
            weeklySales[0] += order.totalAmount;
          else if (day <= 14)
            weeklySales[1] += order.totalAmount;
          else if (day <= 21)
            weeklySales[2] += order.totalAmount;
          else if (day <= 28)
            weeklySales[3] += order.totalAmount;
          else
            weeklySales[4] += order.totalAmount;
        }
      }
    }

    double maxSales = 0;
    for (var s in weeklySales) {
      if (s > maxSales) maxSales = s;
    }
    if (maxSales == 0) maxSales = 1; // avoid division by zero

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trend (This Month)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${currentMonthSales.toStringAsFixed(2)} generated',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),

          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (index) {
                double heightRatio = weeklySales[index] / maxSales;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (weeklySales[index] > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${(weeklySales[index] >= 1000 ? (weeklySales[index] / 1000).toStringAsFixed(1) + 'k' : weeklySales[index].toStringAsFixed(0))}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuart,
                      height: 120 * heightRatio,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: heightRatio > 0.7
                              ? [
                                  const Color(0xFF4776E6),
                                  const Color(0xFF8E54E9),
                                ]
                              : [Colors.blue.shade200, Colors.blue.shade400],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'W${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeTopProducts(
    List<dynamic> products,
    Map<String, double> revenue,
    Map<String, int> qty,
  ) {
    var sorted = revenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                'Top Performers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (sorted.isEmpty)
            const Text('No data available')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length > 5 ? 5 : sorted.length,
              itemBuilder: (context, index) {
                final pId = sorted[index].key;
                final rev = sorted[index].value;
                final q = qty[pId] ?? 0;
                var product;
                try {
                  product = products.firstWhere((p) => p.productId == pId);
                } catch (e) {
                  product = null;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$q units sold',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${rev.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4776E6),
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
}
