import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/rep_dashboard_provider.dart';
import '../../utils/app_theme.dart';

class RepReportsScreen extends StatefulWidget {
  const RepReportsScreen({super.key});

  @override
  State<RepReportsScreen> createState() => _RepReportsScreenState();
}

class _RepReportsScreenState extends State<RepReportsScreen> {
  int _selectedTabIndex = 0; // 0 for Today, 1 for Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Reports'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSegmentedControl(),
          Expanded(
            child: _selectedTabIndex == 0 ? _buildTodayReport() : _buildTrendReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1E1E1E) : AppTheme.primaryColor,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? (isDark ? Colors.grey.shade800 : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 0
                          ? (isDark ? Colors.white : AppTheme.primaryColor)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? (isDark ? Colors.grey.shade800 : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '7 Days Trend',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 1
                          ? (isDark ? Colors.white : AppTheme.primaryColor)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayReport() {
    return Consumer<RepDashboardProvider>(
      builder: (context, provider, child) {
        final visitOrders = provider.todayVisitOrders;
        final hasData = visitOrders.isNotEmpty;
        
        double maxY = 0.0;
        for (var amt in visitOrders) {
          if (amt > maxY) maxY = amt;
        }
        if (maxY == 0) maxY = 1000;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Activity Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Showing order amount per visit today.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: hasData 
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: visitOrders.length > 5 ? (visitOrders.length * 60.0) : MediaQuery.of(context).size.width - 32,
                      child: BarChart(
                        BarChartData(
                          barGroups: visitOrders.asMap().entries.map((entry) {
                            return makeGroupData(entry.key, entry.value, color: AppTheme.primaryColor);
                          }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 16,
                                    child: Text(
                                      'V${value.toInt() + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 38,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const SizedBox();
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 8,
                                    child: Text(
                                      value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}K' : value.toStringAsFixed(0),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY * 1.2,
                        ),
                      ),
                    ),
                  )
                : const Center(child: Text("No visits recorded today.")),
              ),
              const SizedBox(height: 32),
              _buildStatCard(
                'Payments Collected', 
                'Rs. ${provider.todayCollectedPayments.toStringAsFixed(2)}', 
                Icons.payments, 
                Colors.green
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendReport() {
    return Consumer<RepDashboardProvider>(
      builder: (context, provider, child) {
        final weeklySales = provider.weeklySales; // List<double> of length 7
        
        final spots = <FlSpot>[];
        double maxY = 0.0;
        for (int i = 0; i < 7; i++) {
          final val = weeklySales[i];
          spots.add(FlSpot(i.toDouble(), val));
          if (val > maxY) maxY = val;
        }
        
        if (maxY == 0) {
           maxY = 1000; // default scale if no data
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sales Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Showing total sales amount for the last 7 days.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index < 0 || index > 6) return const SizedBox();
                            final date = DateTime.now().subtract(Duration(days: 6 - index));
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            final dateStr = '${date.day} ${months[date.month - 1]}';
                            
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                dateStr, 
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600)
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}K' : value.toStringAsFixed(0),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxY * 1.2, // Give some top padding
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Colors.green.shade700,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                             return FlDotCirclePainter(
                               radius: 4,
                               color: Colors.white,
                               strokeWidth: 2,
                               strokeColor: Colors.green.shade700,
                             );
                          }
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.shade700.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Rs. ${spot.y.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  BarChartGroupData makeGroupData(int x, double y, {Color? color}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color ?? AppTheme.primaryColor,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
