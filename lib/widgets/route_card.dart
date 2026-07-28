import 'package:flutter/material.dart';
import '../models/route_model.dart';
import 'package:intl/intl.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final int shopCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RouteCard({
    super.key,
    required this.route,
    required this.shopCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // slightly smaller margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // reduced padding from 20
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12), // reduced from 14
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 24, // reduced from 28
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(
                            fontSize: 16, // reduced from 18
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (route.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            route.description,
                            style: TextStyle(
                              fontSize: 13, // reduced from 14
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Added ${DateFormat.yMMMd().format(route.createdAt)}',
                            style: TextStyle(
                              fontSize: 11, // reduced from 12
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                spacing: 10,
                children: [
                  // Shop Count Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1), // Green tint
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF15803D)),
                        const SizedBox(width: 6),
                        Text(
                          '$shopCount Shops',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF15803D), // Dark green text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB), // Blue
                          backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626), // Red
                          backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
