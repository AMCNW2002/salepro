import 'package:flutter/material.dart';
import '../models/shop_model.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final String? routeName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShopCard({
    super.key,
    required this.shop,
    this.routeName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.12), // Emerald tint
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF34D399)], // Emerald gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (shop.owner.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${shop.owner}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (shop.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            shop.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
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
                            routeName != null ? 'Route: $routeName' : 'Unassigned',
                            style: TextStyle(
                              fontSize: 11,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: shop.balanceDue > 0
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1) // Red tint
                          : const Color(0xFF22C55E).withValues(alpha: 0.1), // Green tint
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: shop.balanceDue > 0
                            ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                            : const Color(0xFF22C55E).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          shop.balanceDue > 0 ? Icons.account_balance_wallet_outlined : Icons.check_circle_outline,
                          size: 16,
                          color: shop.balanceDue > 0 ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shop.balanceDue > 0 ? 'Due: Rs. ${shop.balanceDue.toStringAsFixed(0)}' : 'Settled',
                          style: TextStyle(
                            fontSize: 12,
                            color: shop.balanceDue > 0 ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
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
                          foregroundColor: const Color(0xFFDC2626),
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
