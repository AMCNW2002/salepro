import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';

class AdminRepPerformanceScreen extends StatefulWidget {
  final UserModel rep;

  const AdminRepPerformanceScreen({super.key, required this.rep});

  @override
  State<AdminRepPerformanceScreen> createState() => _AdminRepPerformanceScreenState();
}

class _AdminRepPerformanceScreenState extends State<AdminRepPerformanceScreen> {
  Future<Map<String, dynamic>> _fetchPerformanceData() async {
    final firestore = FirebaseFirestore.instance;
    final uid = widget.rep.uid;

    final ordersSnap = await firestore.collection('orders').where('repId', isEqualTo: uid).get();
    final paymentsSnap = await firestore.collection('payments').where('repId', isEqualTo: uid).get();
    final visitsSnap = await firestore.collection('visits').where('repId', isEqualTo: uid).get();

    double totalSales = 0;
    for (var doc in ordersSnap.docs) {
      totalSales += (doc.data()['totalAmount'] ?? 0.0).toDouble();
    }

    double totalPayments = 0;
    for (var doc in paymentsSnap.docs) {
      totalPayments += (doc.data()['amount'] ?? 0.0).toDouble();
    }
    
    // Sort orders for recent activity
    final sortedOrders = ordersSnap.docs.toList();
    sortedOrders.sort((a, b) {
      final aTime = a.data()['timestamp'] as Timestamp?;
      final bTime = b.data()['timestamp'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return {
      'totalOrders': ordersSnap.docs.length,
      'totalSales': totalSales,
      'totalPayments': totalPayments,
      'totalVisits': visitsSnap.docs.length,
      'recentOrders': sortedOrders.take(5).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD32F2F), // Red theme
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('${widget.rep.name} Performance'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPerformanceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final data = snapshot.data ?? {};
          final totalSales = data['totalSales'] as double? ?? 0.0;
          final totalPayments = data['totalPayments'] as double? ?? 0.0;
          final totalOrders = data['totalOrders'] as int? ?? 0;
          final totalVisits = data['totalVisits'] as int? ?? 0;
          final recentOrders = data['recentOrders'] as List<QueryDocumentSnapshot>? ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Text(
                    'Key Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMetricCard(
                      'Total Sales',
                      'Rs. ${totalSales.toStringAsFixed(0)}',
                      Icons.shopping_cart_outlined,
                      const Color(0xFFD32F2F),
                    ),
                    _buildMetricCard(
                      'Collected',
                      'Rs. ${totalPayments.toStringAsFixed(0)}',
                      Icons.account_balance_wallet_outlined,
                      const Color(0xFF1976D2),
                    ),
                    _buildMetricCard(
                      'Orders Placed',
                      totalOrders.toString(),
                      Icons.receipt_long_outlined,
                      const Color(0xFF388E3C),
                    ),
                    _buildMetricCard(
                      'Shop Visits',
                      totalVisits.toString(),
                      Icons.store_mall_directory_outlined,
                      const Color(0xFFF57C00),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Activity (Orders)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              if (recentOrders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No recent orders.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = recentOrders[index];
                    final orderData = doc.data() as Map<String, dynamic>;
                    final shopName = orderData['shopName'] ?? 'Unknown Shop';
                    final amount = orderData['totalAmount'] ?? 0.0;
                    final timestamp = orderData['timestamp'] as Timestamp?;
                    
                    final dateStr = timestamp != null
                        ? DateFormat('MMM d, y • h:mm a').format(timestamp.toDate())
                        : 'Unknown Date';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD32F2F)),
                        ),
                        title: Text(
                          shopName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          dateStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          'Rs. ${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: recentOrders.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.rep.name.isNotEmpty ? widget.rep.name[0].toUpperCase() : 'R',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.rep.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.rep.routeId.isNotEmpty ? 'Route: ${widget.rep.routeId}' : 'No Route Assigned',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
