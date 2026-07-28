import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/route_provider.dart';
import '../../../widgets/shop_card.dart';
import 'admin_add_shop_screen.dart';

class AdminShopsScreen extends StatefulWidget {
  const AdminShopsScreen({super.key});

  @override
  State<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends State<AdminShopsScreen> {
  String? _selectedRouteId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchAllShops();
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
      body: Consumer2<ShopProvider, RouteProvider>(
        builder: (context, shopProvider, routeProvider, child) {
          if (shopProvider.isLoading && shopProvider.shops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredShops = shopProvider.shops.where((shop) {
            return shop.name.toLowerCase().contains(_searchQuery) ||
                shop.owner.toLowerCase().contains(_searchQuery);
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20, bottom: 24, left: 20, right: 20),
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
                            'Manage Shops',
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
                              Icons.storefront_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
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
                            hintText: 'Search shops by name or owner...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.search, color: const Color(0xFFD32F2F)),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dropdown Route Filter
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
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedRouteId,
                          decoration: const InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.filter_list, color: Color(0xFFD32F2F)),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Routes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            ),
                            ...routeProvider.routes.map((route) {
                              return DropdownMenuItem(
                                value: route.routeId,
                                child: Text(route.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRouteId = value;
                            });
                            if (value == null) {
                              context.read<ShopProvider>().fetchAllShops();
                            } else {
                              context.read<ShopProvider>().fetchShopsByRoute(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (shopProvider.shops.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No shops created yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the Add Shop button below to get started.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredShops.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No matching shops',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find any shops matching your search.',
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
                      final shop = filteredShops[index];
                      // Find the route name for the shop
                      final routeName = routeProvider.routes
                          .where((r) => r.routeId == shop.routeId)
                          .map((r) => r.name)
                          .firstWhere((_) => true, // ignore: missing_return, always provides a value or empty string
                              orElse: () => 'Unknown Route');

                      return ShopCard(
                        shop: shop,
                        routeName: routeName,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddShopScreen(shopToEdit: shop),
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Delete Shop', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('Are you sure you want to delete "${shop.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    shopProvider.deleteShop(shop.shopId);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }, childCount: filteredShops.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFEF5350)], // Red theme
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
              MaterialPageRoute(builder: (context) => const AdminAddShopScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_business_outlined, color: Colors.white),
          label: const Text(
            'Add Shop',
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
}
