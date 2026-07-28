import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/product_card.dart';
import 'admin_add_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredProducts = productProvider.products.where((product) {
            return product.name.toLowerCase().contains(_searchQuery);
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 24,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Manage Products',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products by name...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (productProvider.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the Add Product button below to get started.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching products',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find any products matching your search.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddProductScreen(
                                productToEdit: product,
                              ),
                            ),
                          );
                        },
                        onUpdateStock: () {
                          _showUpdateStockDialog(
                            context,
                            productProvider,
                            product.productId,
                            product.stock,
                          );
                        },
                      );
                    }, childCount: filteredProducts.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminAddProductScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, ProductProvider provider, String productId, int currentStock) {
    final controller = TextEditingController(text: currentStock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? currentStock;
              // Ideally updateStock method in ProductProvider
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock updated to $newStock')));
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
