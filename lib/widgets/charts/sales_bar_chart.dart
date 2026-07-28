import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesBarChart extends StatelessWidget {
  final List<double> salesData;
  final List<String> labels;

  const SalesBarChart({super.key, required this.salesData, required this.labels});

  @override
  Widget build(BuildContext context) {
    double maxSale = 0;
    if (salesData.isNotEmpty) {
      maxSale = salesData.reduce((curr, next) => curr > next ? curr : next);
    }
    final maxY = maxSale > 0 ? maxSale * 1.2 : 1000.0; // Add 20% headroom

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    'Rs. ${rod.toY.toStringAsFixed(0)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == maxY) return const SizedBox();
                    return Text(
                      '${(value / 1000).toStringAsFixed(1)}k',
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
              horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: salesData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Theme.of(context).colorScheme.primary,
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
