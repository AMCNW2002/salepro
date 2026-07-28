import 'package:flutter/material.dart';
import '../models/user_model.dart';

class RepCard extends StatelessWidget {
  final UserModel rep;
  final VoidCallback onAssignRoute;
  final VoidCallback onViewPerformance;

  const RepCard({
    super.key,
    required this.rep,
    required this.onAssignRoute,
    required this.onViewPerformance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced from 16
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42, // Reduced from 50
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12), // Reduced from 15
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      rep.name.isNotEmpty ? rep.name[0].toUpperCase() : 'R',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Reduced from 22
                        fontWeight: FontWeight.bold,
                      ),
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
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'Sales Rep',
                          style: TextStyle(
                            fontSize: 10, // Reduced from 12
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0), // Reduced from 12
              child: Divider(height: 1, color: Color(0xFFF3F4F6)),
            ),
            Row(
              children: [
                Expanded(child: _buildInfoChip(Icons.phone_outlined, rep.phone)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoChip(Icons.email_outlined, rep.email)),
              ],
            ),
            const SizedBox(height: 12), // Reduced from 16
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onViewPerformance,
                  icon: const Icon(Icons.bar_chart_rounded, size: 14), 
                  label: const Text(
                    'Performance',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4B5563),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), 
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                ),
                const SizedBox(width: 8), 
                ElevatedButton.icon(
                  onPressed: onAssignRoute,
                  icon: const Icon(Icons.map_outlined, size: 14), 
                  label: const Text(
                    'Assign Route',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10), 
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)), // Reduced from 16
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12, // Reduced from 13
              color: Color(0xFF4B5563),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
