import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/shop_provider.dart';
import 'rep_add_shop_sheet.dart';

class AssignShopScreen extends StatefulWidget {
  const AssignShopScreen({super.key});

  @override
  State<AssignShopScreen> createState() => _AssignShopScreenState();
}

class _AssignShopScreenState extends State<AssignShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchUnassignedShops();
    });
  }

  void _assignShop(String shopId, String routeId) async {
    final shopProvider = context.read<ShopProvider>();
    final shop = shopProvider.shops.firstWhere((s) => s.shopId == shopId);

    final success = await shopProvider.updateShop(
      shopId: shop.shopId,
      name: shop.name,
      owner: shop.owner,
      phone: shop.phone,
      address: shop.address,
      routeId: routeId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shopProvider.errorMessage ?? 'Error assigning shop'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<AuthProvider>().currentUserModel;

    if (userModel == null || userModel.routeId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assign Shop')),
        body: const Center(child: Text('You are not assigned to any route.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Shop to Route'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading && shopProvider.shops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopProvider.shops.isEmpty) {
            return const Center(child: Text('No unassigned shops available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shopProvider.shops.length,
            itemBuilder: (context, index) {
              final shop = shopProvider.shops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(shop.address),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _assignShop(shop.shopId, userModel.routeId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Assign'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (context) => RepAddShopSheet(routeId: userModel.routeId),
          );
          
          // Refresh shops when returning
          if (result == true && mounted) {
            context.read<ShopProvider>().fetchUnassignedShops();
          }
        },
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text('Create New Shop', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
