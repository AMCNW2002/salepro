import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onUpdateStock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = product.stock <= 0;
    bool isLowStock = product.stock > 0 && product.stock <= 10; // threshold example
    
    Color statusColor = Colors.green;
    String statusText = 'In Stock';
    
    if (isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Rs. ${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Text('Stock: ${product.stock}', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 22),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: onUpdateStock,
            ),
          ],
        ),
      ),
    );
  }
}
