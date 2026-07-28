import 'package:flutter/material.dart';
import 'admin_card.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final Widget chartPlaceholder; // This will hold the dummy chart image or icon for now

  const ReportCard({
    super.key,
    required this.title,
    required this.chartPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: chartPlaceholder),
          ),
        ],
      ),
    );
  }
}
