import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class CustomerProductSelectionSheet extends StatefulWidget {
  const CustomerProductSelectionSheet({super.key});

  @override
  State<CustomerProductSelectionSheet> createState() => _CustomerProductSelectionSheetState();
}

class _CustomerProductSelectionSheetState extends State<CustomerProductSelectionSheet> {
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
      shopId: userModel.uid,
      shopName: userModel.shopName.isNotEmpty ? userModel.shopName : 'My Shop',
      repId: 'self_order', // special marker for customer self orders
      routeId: userModel.routeId,
      items: items,
      productProvider: provider,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
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
              const Text('Place New Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A2D3E))),
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
              hintText: 'Search available products...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2A2D3E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No products available', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2A2D3E)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs. ${product.price.toStringAsFixed(2)}', 
                                    style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Available: ${product.stock}', 
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2D3E).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: qty > 0 ? const Color(0xFFD32F2F) : Colors.grey,
                                    onPressed: () => _decrementQty(product),
                                  ),
                                  Text(
                                    '$qty', 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A2D3E)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: qty < product.stock ? Colors.green : Colors.grey,
                                    onPressed: () => _incrementQty(product),
                                  ),
                                ],
                              ),
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
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      'Rs. ${_calculateTotal().toStringAsFixed(2)}', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2A2D3E)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _cart.isEmpty || context.watch<OrderProvider>().isLoading ? null : _createOrder,
                  icon: context.watch<OrderProvider>().isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: const Color(0xFF2A2D3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
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
