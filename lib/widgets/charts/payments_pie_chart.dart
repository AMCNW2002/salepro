import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentsPieChart extends StatefulWidget {
  final Map<String, double> paymentsData;

  const PaymentsPieChart({super.key, required this.paymentsData});

  @override
  State<PaymentsPieChart> createState() => _PaymentsPieChartState();
}

class _PaymentsPieChartState extends State<PaymentsPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.paymentsData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No payment data available')),
      );
    }

    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: widget.paymentsData.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final MapEntry<String, double> mapEntry = entry.value;
                  
                  final isTouched = index == touchedIndex;
                  final fontSize = isTouched ? 20.0 : 16.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  final color = colors[index % colors.length];

                  return PieChartSectionData(
                    color: color,
                    value: mapEntry.value,
                    title: '${mapEntry.value.toInt()}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.paymentsData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final mapEntry = entry.value;
              final color = colors[index % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mapEntry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: touchedIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
