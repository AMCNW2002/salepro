import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/alert_card.dart';

class AdminStockAlertScreen extends StatefulWidget {
  const AdminStockAlertScreen({super.key});

  @override
  State<AdminStockAlertScreen> createState() => _AdminStockAlertScreenState();
}

class _AdminStockAlertScreenState extends State<AdminStockAlertScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alerts'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final lowStockProducts = productProvider.products.where((p) => p.stock <= 10).toList();

          if (lowStockProducts.isEmpty) {
            return const Center(
              child: Text(
                'No stock alerts!\nAll products are sufficiently stocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Sort so out of stock (<=0) appears first
          lowStockProducts.sort((a, b) => a.stock.compareTo(b.stock));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              return AlertCard(
                product: product,
                onActionPressed: () {
                  // Usually navigates to update stock or opens dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update stock for ${product.name}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
