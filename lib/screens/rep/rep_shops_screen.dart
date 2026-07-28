import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/visit_provider.dart';
import 'rep_add_shop_sheet.dart';
import 'shop_detail_screen.dart';
import 'product_selection_sheet.dart';
import 'payment_collection_sheet.dart';

class RepShopsScreen extends StatefulWidget {
  const RepShopsScreen({super.key});

  @override
  State<RepShopsScreen> createState() => _RepShopsScreenState();
}

class _RepShopsScreenState extends State<RepShopsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userModel = context.read<AuthProvider>().currentUserModel;
      if (userModel != null && userModel.routeId.isNotEmpty) {
        context.read<ShopProvider>().fetchShopsByRoute(userModel.routeId);
        context.read<VisitProvider>().getVisitsByRep(userModel.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<AuthProvider>().currentUserModel;

    if (userModel == null || userModel.routeId.isEmpty) {
      return const Center(child: Text('No route assigned yet.'));
    }

    return Scaffold(
      body: Consumer2<ShopProvider, VisitProvider>(
        builder: (context, shopProvider, visitProvider, child) {
          if (shopProvider.isLoading && shopProvider.shops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopProvider.shops.isEmpty) {
            return const Center(child: Text('No shops found on your route.'));
          }

          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shopProvider.shops.length,
            itemBuilder: (context, index) {
              final shop = shopProvider.shops[index];
              final isVisited = visitProvider.repVisits.any(
                (v) =>
                    v.shopId == shop.shopId && v.timestamp.isAfter(startOfDay),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailScreen(shop: shop),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Shop Avatar
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isVisited
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.store_mall_directory_rounded,
                                    color: isVisited
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Shop Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              shop.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black87,
                                                letterSpacing: -0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isVisited
                                                  ? Colors.green.shade50
                                                  : Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isVisited
                                                    ? Colors.green.shade200
                                                    : Colors.orange.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isVisited)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 10,
                                                    color:
                                                        Colors.green.shade700,
                                                  )
                                                else
                                                  Icon(
                                                    Icons
                                                        .pending_actions_rounded,
                                                    size: 10,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  isVisited
                                                      ? 'Visited'
                                                      : 'Pending',
                                                  style: TextStyle(
                                                    color: isVisited
                                                        ? Colors.green.shade700
                                                        : Colors
                                                              .orange
                                                              .shade800,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${shop.owner} • ${shop.phone}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              shop.address,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Compact Balance Row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Balance:',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rs. ${shop.balanceDue.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: shop.balanceDue > 0
                                                  ? Colors.red.shade700
                                                  : Colors.green.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                if (!isVisited) ...[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                title: const Text('Mark Visited?'),
                                                content: Text('Mark ${shop.name} as visited today?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      final repId = context.read<AuthProvider>().currentUserModel!.uid;
                                                      await context.read<VisitProvider>().markVisit(
                                                        shopId: shop.shopId,
                                                        repId: repId,
                                                        routeId: shop.routeId,
                                                      );
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Visit Marked!'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: const Text('Confirm'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.directions_walk, color: Colors.white, size: 16),
                                                SizedBox(width: 6),
                                                Text('Visit', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                ProductSelectionSheet(shop: shop),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text('Order', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF059669).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                PaymentCollectionSheet(shop: shop),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.payments, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text('Collect', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final userModel = context.read<AuthProvider>().currentUserModel;
          if (userModel == null || userModel.routeId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No route assigned. Cannot add shop.'),
              ),
            );
            return;
          }

          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (context) => RepAddShopSheet(routeId: userModel.routeId),
          );

          if (!context.mounted) return;
          // Refresh shops when returning
          if (result == true) {
            context.read<ShopProvider>().fetchShopsByRoute(userModel.routeId);
          }
        },
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text('Add Shop', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
