import re

file_path = r'c:\Users\User\Desktop\New folder\salepro\lib\screens\admin\admin_reports_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "  Widget _buildRouteAnalyticsSection() {"
end_marker = "  Widget _buildRepAnalyticsSection() {"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("Could not find markers.")
    exit(1)

new_content = """  Widget _buildRouteAnalyticsSection() {
    return Consumer4<RouteProvider, OrderProvider, ShopProvider, RepProvider>(
      builder: (context, routeProvider, orderProvider, shopProvider, repProvider, child) {
        final routes = routeProvider.routes;
        final orders = orderProvider.orders;
        final shops = shopProvider.shops;
        final reps = repProvider.reps;

        final now = DateTime.now();

        Map<String, double> routeSales = {};
        Map<String, int> routeCompletedOrders = {};
        Map<String, Set<String>> routeCustomersServed = {};
        Map<String, double> routeSalesMonthly = {};
        Map<String, double> routeSalesWeekly = {};
        Map<String, int> routeTotalCustomers = {};

        for (var shop in shops) {
          routeTotalCustomers[shop.routeId] = (routeTotalCustomers[shop.routeId] ?? 0) + 1;
        }

        for (var order in orders) {
          if (order.status.toLowerCase() == 'cancelled' || order.status.toLowerCase() == 'pending') continue;

          String rId = order.routeId;
          routeSales[rId] = (routeSales[rId] ?? 0.0) + order.totalAmount;
          routeCompletedOrders[rId] = (routeCompletedOrders[rId] ?? 0) + 1;

          routeCustomersServed.putIfAbsent(rId, () => <String>{});
          routeCustomersServed[rId]!.add(order.shopId);

          if (order.timestamp.year == now.year && order.timestamp.month == now.month) {
            routeSalesMonthly[rId] = (routeSalesMonthly[rId] ?? 0.0) + order.totalAmount;
          }
          if (now.difference(order.timestamp).inDays <= 7) {
            routeSalesWeekly[rId] = (routeSalesWeekly[rId] ?? 0.0) + order.totalAmount;
          }
        }

        String bestSalesRouteId = '';
        double maxSales = -1;
        String bestDeliveryRouteId = '';
        int maxDeliveries = -1;
        String lowestRouteId = '';
        double minSales = double.maxFinite;

        double totalRouteSales = 0;
        int activeRoutesCount = 0;
        int totalCustomersCovered = 0;

        for (var r in routes) {
          double sales = routeSales[r.routeId] ?? 0.0;
          int deliveries = routeCompletedOrders[r.routeId] ?? 0;

          totalRouteSales += sales;
          if (sales > 0 || deliveries > 0) activeRoutesCount++;
          totalCustomersCovered += (routeCustomersServed[r.routeId]?.length ?? 0);

          if (sales > maxSales) {
            maxSales = sales;
            bestSalesRouteId = r.routeId;
          }
          if (deliveries > maxDeliveries) {
            maxDeliveries = deliveries;
            bestDeliveryRouteId = r.routeId;
          }
          if (sales < minSales && sales > 0) {
            minSales = sales;
            lowestRouteId = r.routeId;
          }
        }

        if (minSales == double.maxFinite) minSales = 0.0;

        var rankedRoutes = routes.toList();
        rankedRoutes.sort((a, b) => (routeSales[b.routeId] ?? 0.0).compareTo(routeSales[a.routeId] ?? 0.0));

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Route Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Interactive dashboard for route performance and coverage.', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              _buildCreativeRouteSummaryCards(
                routes, bestSalesRouteId, bestDeliveryRouteId, lowestRouteId,
                routeSales, routeCompletedOrders, routeCustomersServed,
                activeRoutesCount, totalCustomersCovered, totalRouteSales
              ),
              const SizedBox(height: 32),

              LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth >= 1000;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildCreativeRouteRanking(rankedRoutes, routeSales, routeCompletedOrders, routeCustomersServed, reps, totalRouteSales),
                              const SizedBox(height: 24),
                              _buildCreativeCustomerCoverage(routes, routeTotalCustomers, routeCustomersServed),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildCreativeRouteComparison(rankedRoutes, routeSales, routeSalesMonthly, routeSalesWeekly, routeCompletedOrders, totalRouteSales),
                              const SizedBox(height: 24),
                              _buildCreativeRepRouteAssignment(reps, routes, routeSales, routeCompletedOrders, routeCustomersServed),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCreativeRouteRanking(rankedRoutes, routeSales, routeCompletedOrders, routeCustomersServed, reps, totalRouteSales),
                        const SizedBox(height: 24),
                        _buildCreativeRouteComparison(rankedRoutes, routeSales, routeSalesMonthly, routeSalesWeekly, routeCompletedOrders, totalRouteSales),
                        const SizedBox(height: 24),
                        _buildCreativeCustomerCoverage(routes, routeTotalCustomers, routeCustomersServed),
                        const SizedBox(height: 24),
                        _buildCreativeRepRouteAssignment(reps, routes, routeSales, routeCompletedOrders, routeCustomersServed),
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

  Widget _buildCreativeRouteSummaryCards(
    List<RouteModel> routes, String bestSalesId, String bestDelId, String lowestId,
    Map<String, double> routeSales, Map<String, int> routeCompletedOrders, Map<String, Set<String>> routeCustomersServed,
    int activeRoutesCount, int totalCustomersCovered, double totalRouteSales
  ) {
    String bestSalesName = 'N/A';
    String bestDelName = 'N/A';
    String lowestName = 'N/A';
    try { bestSalesName = routes.firstWhere((r) => r.routeId == bestSalesId).name; } catch (e) {}
    try { bestDelName = routes.firstWhere((r) => r.routeId == bestDelId).name; } catch (e) {}
    try { lowestName = routes.firstWhere((r) => r.routeId == lowestId).name; } catch (e) {}

    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth >= 900;
      return GridView.count(
        crossAxisCount: isDesktop ? 4 : (constraints.maxWidth >= 600 ? 2 : 1),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.6 : 2.0,
        children: [
          _buildSleekMetricCard('Top Route (Sales)', bestSalesName, Icons.emoji_events, [const Color(0xFFf12711), const Color(0xFFf5af19)]),
          _buildSleekMetricCard('Top Route (Orders)', bestDelName, Icons.local_shipping, [const Color(0xFF00B4DB), const Color(0xFF0083B0)]),
          _buildSleekMetricCard('Lowest Route', lowestName, Icons.warning_amber_rounded, [const Color(0xFFED213A), const Color(0xFF93291E)]),
          _buildSleekMetricCard('Total Active Routes', activeRoutesCount.toString(), Icons.map, [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
        ],
      );
    });
  }

  Widget _buildCreativeRouteRanking(
    List<RouteModel> rankedRoutes, Map<String, double> routeSales, Map<String, int> routeCompletedOrders,
    Map<String, Set<String>> routeCustomersServed, List<dynamic> reps, double totalRouteSales
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top Performing Routes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (rankedRoutes.isEmpty) const Text('No routes available') else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankedRoutes.length > 5 ? 5 : rankedRoutes.length,
            itemBuilder: (context, index) {
              RouteModel r = rankedRoutes[index];
              double sales = routeSales[r.routeId] ?? 0.0;
              int orders = routeCompletedOrders[r.routeId] ?? 0;
              double perf = totalRouteSales > 0 ? (sales / totalRouteSales) * 100 : 0.0;
              
              var rep;
              try { rep = reps.firstWhere((p) => p.routeId == r.routeId); } catch (e) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: index == 0 ? [Colors.orange.shade400, Colors.red.shade400] : [Colors.blue.shade400, Colors.purple.shade400]), 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Center(child: Text('#${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Rep: ${rep?.name ?? 'Unassigned'} • $orders orders', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs. ${sales.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF4776E6))),
                        const SizedBox(height: 4),
                        Text('${perf.toStringAsFixed(1)}% share', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
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

  Widget _buildCreativeRouteComparison(
    List<RouteModel> routes, Map<String, double> sales, Map<String, double> monthly,
    Map<String, double> weekly, Map<String, int> orders, double totalRouteSales
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Route Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          ...routes.take(3).map((r) {
            double rMonthly = monthly[r.routeId] ?? 0.0;
            double pct = totalRouteSales > 0 ? ((sales[r.routeId] ?? 0.0) / totalRouteSales) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('Rs. ${rMonthly.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCreativeCustomerCoverage(
    List<RouteModel> routes, Map<String, int> totalCustomers, Map<String, Set<String>> servedCustomers
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Coverage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          ...routes.take(3).map((r) {
            int total = totalCustomers[r.routeId] ?? 0;
            int served = servedCustomers[r.routeId]?.length ?? 0;
            double coverage = total > 0 ? (served / total) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 48, width: 48,
                        child: CircularProgressIndicator(
                          value: coverage,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(coverage > 0.7 ? Colors.green.shade400 : Colors.orange.shade400),
                        ),
                      ),
                      Text('${(coverage * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('$served / $total customers served', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCreativeRepRouteAssignment(
    List<dynamic> reps, List<RouteModel> routes, Map<String, double> routeSales,
    Map<String, int> routeCompletedOrders, Map<String, Set<String>> routeCustomersServed
  ) {
    var activeReps = reps.where((r) => r.routeId.isNotEmpty).toList();
    if (activeReps.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rep Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          ...activeReps.take(3).map((rep) {
            String rName = 'Unknown Route';
            try { rName = routes.firstWhere((r) => r.routeId == rep.routeId).name; } catch (e) {}
            double sales = routeSales[rep.routeId] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, color: Colors.blue.shade700)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rep.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(rName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('Rs. ${sales.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF4776E6))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
"""

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content[:start_idx] + new_content + "\n" + content[end_idx:])
print("Successfully replaced Route Analytics section!")
