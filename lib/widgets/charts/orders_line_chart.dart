import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OrdersLineChart extends StatelessWidget {
  final List<double> ordersData;
  final List<String> labels;

  const OrdersLineChart({super.key, required this.ordersData, required this.labels});

  @override
  Widget build(BuildContext context) {
    double maxOrder = 0;
    if (ordersData.isNotEmpty) {
      maxOrder = ordersData.reduce((curr, next) => curr > next ? curr : next);
    }
    final maxY = maxOrder > 0 ? maxOrder * 1.2 : 10.0;

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0),
        child: LineChart(
          LineChartData(
            maxY: maxY,
            minY: 0,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toInt()} Orders',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[value.toInt()],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: maxY / 4 > 0 ? (maxY / 4).ceilToDouble() : 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4 > 0 ? (maxY / 4).ceilToDouble() : 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: ordersData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
