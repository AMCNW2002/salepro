import 'package:flutter/material.dart';
import '../models/product_model.dart';

class AlertCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onActionPressed;

  const AlertCard({
    super.key,
    required this.product,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = product.stock <= 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOutOfStock ? Colors.red.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isOutOfStock ? Colors.red.shade200 : Colors.orange.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isOutOfStock ? Icons.error_outline : Icons.warning_amber_rounded,
              color: isOutOfStock ? Colors.red : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOutOfStock ? 'Out of Stock' : 'Low Stock (${product.stock} remaining)',
                    style: TextStyle(
                      color: isOutOfStock ? Colors.red.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutOfStock ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }
}
