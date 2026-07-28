import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/shop_model.dart';
import '../../../models/product_model.dart';
import '../../../models/order_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';

class ProductSelectionSheet extends StatefulWidget {
  final ShopModel shop;

  const ProductSelectionSheet({super.key, required this.shop});

  @override
  State<ProductSelectionSheet> createState() => _ProductSelectionSheetState();
}

class _ProductSelectionSheetState extends State<ProductSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  final Map<String, int> _cart = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getProducts();
      _filterProducts('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    final provider = context.read<ProductProvider>();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(provider.products);
      } else {
        _filteredProducts = provider.products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _incrementQty(ProductModel product) {
    setState(() {
      int current = _cart[product.productId] ?? 0;
      if (current < product.stock) {
        _cart[product.productId] = current + 1;
      }
    });
  }

  void _decrementQty(ProductModel product) {
    setState(() {
      int current = _cart[product.productId] ?? 0;
      if (current > 0) {
        _cart[product.productId] = current - 1;
        if (_cart[product.productId] == 0) {
          _cart.remove(product.productId);
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    final provider = context.read<ProductProvider>();
    for (var entry in _cart.entries) {
      final product = provider.products.firstWhere((p) => p.productId == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  void _createOrder() async {
    if (_cart.isEmpty) return;

    final userModel = context.read<AuthProvider>().currentUserModel;
    if (userModel == null) return;

    final provider = context.read<ProductProvider>();
    List<OrderItemModel> items = _cart.entries.map((entry) {
      final product = provider.products.firstWhere((p) => p.productId == entry.key);
      return OrderItemModel(
        productId: product.productId,
        productName: product.name,
        qty: entry.value,
        price: product.price,
        subtotal: product.price * entry.value,
      );
    }).toList();

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.createOrder(
      shopId: widget.shop.shopId,
      shopName: widget.shop.name,
      repId: userModel.uid,
      routeId: userModel.routeId,
      items: items,
      productProvider: provider,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderProvider.errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: _filterProducts,
          ),
          const SizedBox(height: 16),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_filteredProducts.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }

                return ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final qty = _cart[product.productId] ?? 0;
                    final isOutOfStock = product.stock == 0;

                    if (isOutOfStock) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Rs. ${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.red.shade800)),
                                  const SizedBox(height: 4),
                                  Text('Stock: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: qty > 0 ? Colors.red : Colors.grey,
                                  onPressed: () => _decrementQty(product),
                                ),
                                Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: qty < product.stock ? Colors.green : Colors.grey,
                                  onPressed: () => _incrementQty(product),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Total & Checkout
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.grey)),
                    Text('Rs. ${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _cart.isEmpty || context.watch<OrderProvider>().isLoading ? null : _createOrder,
                  icon: context.watch<OrderProvider>().isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.check),
                  label: const Text('Confirm Order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
