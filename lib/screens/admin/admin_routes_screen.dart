import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/route_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../widgets/route_card.dart';
import 'create_route_screen.dart';

class AdminRoutesScreen extends StatefulWidget {
  const AdminRoutesScreen({super.key});

  @override
  State<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends State<AdminRoutesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final shopProvider = context.watch<ShopProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          if (routeProvider.isLoading && routeProvider.routes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRoutes = routeProvider.routes.where((route) {
            final nameMatch = route.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final descMatch = route.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            return nameMatch || descMatch;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 24,
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
                            'Manage Routes',
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
                              Icons.map_outlined,
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
                          borderRadius: BorderRadius.circular(25),
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
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search routes...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.search,
                                color: const Color(0xFFD32F2F),
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

              if (routeProvider.routes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_road_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No routes created yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the Add Route button below to get started.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredRoutes.isEmpty)
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
                          'No matching routes',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find any route matching "$_searchQuery".',
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
                      final route = filteredRoutes[index];
                      final shopCount = shopProvider.shops.where((s) => s.routeId == route.routeId).length;
                      
                      return RouteCard(
                        route: route,
                        shopCount: shopCount,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRouteScreen(
                                routeId: route.routeId,
                                initialName: route.name,
                                initialDescription: route.description,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Delete Route',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                'Are you sure you want to delete "${route.name}"? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    routeProvider.deleteRoute(route.routeId);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }, childCount: filteredRoutes.length),
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
              MaterialPageRoute(
                builder: (context) => const CreateRouteScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(
            Icons.add_location_alt_outlined,
            color: Colors.white,
          ),
          label: const Text(
            'Add Route',
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
