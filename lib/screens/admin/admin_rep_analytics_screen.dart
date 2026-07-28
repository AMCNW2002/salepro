import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/order_provider.dart';
import '../../../providers/route_provider.dart';

import '../../../providers/rep_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/route_model.dart';
import '../../../models/user_model.dart';
import '../../../models/visit_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepAnalyticsScreen extends StatefulWidget {
  const AdminRepAnalyticsScreen({super.key});

  @override
  State<AdminRepAnalyticsScreen> createState() =>
      _AdminRepAnalyticsScreenState();
}

class _AdminRepAnalyticsScreenState extends State<AdminRepAnalyticsScreen> {
  List<VisitModel> _allVisits = [];
  bool _visitsLoaded = false;
  static const double defaultMonthlyTarget = 500000.0;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('visits')
          .get();
      if (mounted) {
        setState(() {
          _allVisits = snapshot.docs
              .map((doc) => VisitModel.fromMap(doc.data(), doc.id))
              .toList();
          _visitsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching visits: $e');
      if (mounted) {
        setState(() => _visitsLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RepAnalytics'),
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
                _buildRepAnalyticsSection(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepAnalyticsSection() {
    if (!_visitsLoaded) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFC62828)),
        ),
      );
    }

    final reps = context.watch<RepProvider>().reps;
    final orders = context.watch<OrderProvider>().orders;
    final payments = context.watch<PaymentProvider>().payments;
    final routes = context.watch<RouteProvider>().routes;

    Map<String, double> repSales = {};
    Map<String, int> repOrdersCount = {};
    Map<String, double> repCollections = {};
    Map<String, int> repVisitsCount = {};
    Map<String, int> repVisitsPending = {};

    for (var r in reps) {
      repSales[r.uid] = 0.0;
      repOrdersCount[r.uid] = 0;
      repCollections[r.uid] = 0.0;
      repVisitsCount[r.uid] = 0;
      repVisitsPending[r.uid] = 0;
    }

    for (var o in orders) {
      if (repSales.containsKey(o.repId) && o.status != 'cancelled') {
        repSales[o.repId] = (repSales[o.repId] ?? 0) + o.totalAmount;
        repOrdersCount[o.repId] = (repOrdersCount[o.repId] ?? 0) + 1;
      }
    }

    for (var p in payments) {
      if (repCollections.containsKey(p.repId)) {
        repCollections[p.repId] = (repCollections[p.repId] ?? 0) + p.amount;
      }
    }

    for (var v in _allVisits) {
      if (repVisitsCount.containsKey(v.repId)) {
        if (v.visited) {
          repVisitsCount[v.repId] = (repVisitsCount[v.repId] ?? 0) + 1;
        } else {
          repVisitsPending[v.repId] = (repVisitsPending[v.repId] ?? 0) + 1;
        }
      }
    }

    List<UserModel> rankedReps = List.from(reps);
    rankedReps.sort(
      (a, b) => (repSales[b.uid] ?? 0).compareTo(repSales[a.uid] ?? 0),
    );

    double totalSales = repSales.values.fold(0, (acc, val) => acc + val);
    int totalVisits = repVisitsCount.values.fold(0, (acc, val) => acc + val);
    int totalPending = repVisitsPending.values.fold(0, (acc, val) => acc + val);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Representative Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor sales representative performance, customer visits, and productivity.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          _buildCreativeRepSummaryCards(
            totalSales,
            reps.length,
            totalVisits,
            totalPending,
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
                          _buildCreativeRepRanking(
                            rankedReps,
                            repSales,
                            repOrdersCount,
                            repCollections,
                            routes,
                          ),
                          const SizedBox(height: 24),
                          _buildCreativeRepVisitPerformance(
                            rankedReps,
                            repVisitsCount,
                            repVisitsPending,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildCreativeRepPerformanceDetails(
                            rankedReps,
                            repSales,
                            repOrdersCount,
                            repCollections,
                            routes,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreativeRepRanking(
                      rankedReps,
                      repSales,
                      repOrdersCount,
                      repCollections,
                      routes,
                    ),
                    const SizedBox(height: 24),
                    _buildCreativeRepVisitPerformance(
                      rankedReps,
                      repVisitsCount,
                      repVisitsPending,
                    ),
                    const SizedBox(height: 24),
                    _buildCreativeRepPerformanceDetails(
                      rankedReps,
                      repSales,
                      repOrdersCount,
                      repCollections,
                      routes,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeRepSummaryCards(
    double totalSales,
    int totalReps,
    int totalVisits,
    int totalPending,
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
              'Total Sales',
              'Rs. ${totalSales.toStringAsFixed(0)}',
              Icons.payments,
              [Colors.green.shade300, Colors.green.shade400],
            ),
            _buildSleekMetricCard(
              'Active Reps',
              totalReps.toString(),
              Icons.people,
              [Colors.blue.shade300, Colors.blue.shade400],
            ),
            _buildSleekMetricCard(
              'Completed Visits',
              totalVisits.toString(),
              Icons.check_circle,
              [Colors.purple.shade300, Colors.purple.shade400],
            ),
            _buildSleekMetricCard(
              'Pending Visits',
              totalPending.toString(),
              Icons.schedule,
              [Colors.orange.shade300, Colors.orange.shade400],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreativeRepRanking(
    List<UserModel> rankedReps,
    Map<String, double> repSales,
    Map<String, int> repOrders,
    Map<String, double> repCollections,
    List<RouteModel> routes,
  ) {
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
                'Top Performing Reps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.emoji_events, color: Colors.amber.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (rankedReps.isEmpty)
            const Text('No reps available')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rankedReps.length > 5 ? 5 : rankedReps.length,
              itemBuilder: (context, index) {
                UserModel rep = rankedReps[index];
                double sales = repSales[rep.uid] ?? 0.0;
                int orders = repOrders[rep.uid] ?? 0;

                String routeName = 'Unknown';
                try {
                  routeName = routes
                      .firstWhere((r) => r.routeId == rep.routeId)
                      .name;
                } catch (e) {}

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
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
                            colors: index == 0
                                ? [Colors.orange.shade400, Colors.red.shade400]
                                : [
                                    Colors.blue.shade400,
                                    Colors.purple.shade400,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rep.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Route: $routeName • $orders orders',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${sales.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4776E6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (sales >= defaultMonthlyTarget
                                          ? Colors.green
                                          : Colors.orange)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sales >= defaultMonthlyTarget
                                  ? 'On Target'
                                  : 'Below Target',
                              style: TextStyle(
                                color: sales >= defaultMonthlyTarget
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildCreativeRepVisitPerformance(
    List<UserModel> reps,
    Map<String, int> repVisitsCount,
    Map<String, int> repVisitsPending,
  ) {
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
            'Customer Visit Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ...reps.take(4).map((rep) {
            int completed = repVisitsCount[rep.uid] ?? 0;
            int pending = repVisitsPending[rep.uid] ?? 0;
            int total = completed + pending;
            double rate = total > 0 ? (completed / total) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rep.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$completed / $total Visited',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        rate > 0.8
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                      ),
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

  Widget _buildCreativeRepPerformanceDetails(
    List<UserModel> reps,
    Map<String, double> repSales,
    Map<String, int> repOrdersCount,
    Map<String, double> repCollections,
    List<RouteModel> routes,
  ) {
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
            'Rep Profiles Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ...reps.take(5).map((rep) {
            double sales = repSales[rep.uid] ?? 0.0;
            double collections = repCollections[rep.uid] ?? 0.0;
            int orders = repOrdersCount[rep.uid] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          rep.name.isNotEmpty ? rep.name[0] : '?',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rep.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${rep.uid.substring(0, 6)}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${sales.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Orders', orders.toString()),
                      _buildMiniStat(
                        'Collections',
                        'Rs. ${collections.toStringAsFixed(0)}',
                      ),
                      _buildMiniStat(
                        'Performance',
                        sales >= defaultMonthlyTarget ? 'Good' : 'Avg',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
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
