import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rep_stat_card.dart';
import '../../widgets/page_transition_switcher.dart';
import '../../providers/rep_dashboard_provider.dart';
import 'package:intl/intl.dart';
import '../rep/rep_shops_screen.dart';
import '../rep/rep_orders_screen.dart';
import '../rep/rep_payments_screen.dart';
import '../rep/rep_profile_screen.dart';
import '../rep/rep_reports_screen.dart';
import '../rep/shop_detail_screen.dart';
import '../../providers/visit_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../settings/app_settings_screen.dart';
import '../settings/language_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/about_app_screen.dart';
import '../../services/notification_service.dart';

class RepDashboard extends StatefulWidget {
  const RepDashboard({super.key});

  @override
  State<RepDashboard> createState() => _RepDashboardState();
}

class _RepDashboardState extends State<RepDashboard> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];
  Timer? _refreshTimer;
  late final List<Widget> _pages;
  String? _currentRouteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<RepDashboardProvider>().fetchDashboardStats(
          user.uid,
          user.routeId,
        );
        context.read<VisitProvider>().getVisitsByRep(user.uid);
        // Start tracking rep location
        context.read<LocationProvider>().startTracking();
        
        _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            context.read<RepDashboardProvider>().fetchDashboardStats(
              user.uid,
              user.routeId,
            );
          }
        });
      }
    });

    _pages = [
      _RepDashboardMain(
        onNavigate: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _navigationHistory.add(index);
            });
          }
        },
      ),
      const RepShopsScreen(),
      const RepOrdersScreen(),
      const RepPaymentsScreen(),
      const RepReportsScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthProvider>().currentUserModel;
    if (user != null && user.routeId != _currentRouteId) {
      _currentRouteId = user.routeId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && user.routeId.isNotEmpty) {
          context.read<ShopProvider>().fetchShopsByRoute(user.routeId);
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    // Stop tracking when leaving dashboard (if context is still valid, though using a global singleton or just calling it directly is safer. Actually, Provider.of(..., listen: false) might throw if widget is unmounted. Let's just leave it or use the provider)
    try {
      context.read<LocationProvider>().stopTracking();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserModel;

    return WillPopScope(
      onWillPop: () async {
        if (_navigationHistory.length > 1) {
          setState(() {
            _navigationHistory.removeLast();
            _currentIndex = _navigationHistory.last;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
      drawer: _currentIndex == 0
          ? Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // Removes ExpansionTile borders
              ),
              child: Drawer(
                backgroundColor: const Color(0xFFF8F9FA), // Very light grey background
                surfaceTintColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Creative Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 235, 87, 87),
                            Color.fromARGB(255, 180, 40, 40),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white,
                              child: Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0].toUpperCase()
                                    : 'R',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 215, 51, 51),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.name ?? 'Representative',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user?.email ?? 'Sales Team',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Menu Items
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              leading: Icon(Icons.person_outline, color: Colors.grey.shade700),
                              title: Text('My Profile', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RepProfileScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Notifications Section
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              leading: Icon(Icons.notifications_none, color: Colors.grey.shade700),
                              title: Text('Notifications', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.notifications_active_outlined, size: 20, color: Colors.grey.shade600),
                                  title: Text('Alerts', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () { Navigator.pop(context); },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.campaign_outlined, size: 20, color: Colors.grey.shade600),
                                  title: Text('Announcements', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () { Navigator.pop(context); },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Settings Section
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              leading: Icon(Icons.settings_outlined, color: Colors.grey.shade700),
                              title: Text('Settings', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.tune, size: 20, color: Colors.grey.shade600),
                                  title: Text('App Settings', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen()));
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.language, size: 20, color: Colors.grey.shade600),
                                  title: Text('Language', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                                  },
                                ),
                                Consumer<SettingsProvider>(
                                  builder: (context, settings, child) {
                                    return ListTile(
                                      contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                      leading: Icon(Icons.dark_mode_outlined, size: 20, color: Colors.grey.shade600),
                                      title: Text('Dark Mode', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                      trailing: Switch(
                                        value: settings.isDarkMode,
                                        onChanged: (val) {
                                          settings.toggleTheme(val);
                                        },
                                        activeColor: const Color.fromARGB(255, 215, 51, 51),
                                      ),
                                      onTap: () {
                                        settings.toggleTheme(!settings.isDarkMode);
                                      },
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.help_outline, size: 20, color: Colors.grey.shade600),
                                  title: Text('Help & Support', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 54, right: 16),
                                  leading: Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
                                  title: Text('About App', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen()));
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.black12, height: 1),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'ACCOUNT',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red.shade500, Colors.red.shade800],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade300.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.white.withValues(alpha: 0.2),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                  context.read<AuthProvider>().logout();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.power_settings_new, color: Colors.white, size: 22),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        'Secure Logout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      appBar: _currentIndex == 0
          ? AppBar(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              foregroundColor: Colors.white,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rep Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your Daily Overview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined, size: 24, color: Colors.white),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE53935),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (user != null) {
                        _showNotificationsSheet(context, user.uid);
                      }
                    },
                  ),
                ),
              ],
            )
          : null,
      body: PageTransitionSwitcher(
        index: _currentIndex,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _navigationHistory.add(index);
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_mall_directory_outlined),
            selectedIcon: Icon(Icons.store_mall_directory),
            label: 'My Shops',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    ));
  }

  void _showNotificationsSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: NotificationService().streamNotifications(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No new notifications'));
                    }
                    
                    final notifications = snapshot.data!;
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notif.isRead ? Colors.grey.shade200 : Colors.red.shade100,
                            child: Icon(
                              Icons.notifications,
                              color: notif.isRead ? Colors.grey : Colors.red,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(notif.body),
                          onTap: () {
                            if (!notif.isRead) {
                              NotificationService().markAsRead(uid, notif.id);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RepDashboardMain extends StatelessWidget {
  final Function(int)? onNavigate;

  const _RepDashboardMain({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserModel;
    final dashboardProvider = context.watch<RepDashboardProvider>();
    final visitProvider = context.watch<VisitProvider>();
    final shopProvider = context.watch<ShopProvider>();
    final dateFormat = DateFormat('MMM d, yyyy\nEEEE');

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color.fromARGB(221, 215, 51, 51),
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'R',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${user?.name ?? "Rep"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rep - ${user?.routeId.isNotEmpty == true ? user!.routeId : 'Unassigned'}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dateFormat.format(DateTime.now()),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  if (dashboardProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.05,
                      children: [
                        RepStatCard(
                          title: 'Shops\nAssigned',
                          value: '${shopProvider.shops.length}',
                          icon: Icons.store,
                          iconColor: Colors.green,
                        ),
                        RepStatCard(
                          title: 'Visited\nToday',
                          value: '${dashboardProvider.todayVisits}',
                          icon: Icons.person_pin_circle,
                          iconColor: Colors.blue,
                        ),
                        RepStatCard(
                          title: 'Orders\nToday',
                          value: '${dashboardProvider.todayOrders}',
                          icon: Icons.add_shopping_cart,
                          iconColor: Colors.orange,
                        ),
                        RepStatCard(
                          title: 'Collection\nToday',
                          value:
                              'Rs. ${dashboardProvider.todayCollectedPayments.toStringAsFixed(0)}',
                          icon: Icons.payments,
                          iconColor: Colors.purple,
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // Route Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Route -',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onNavigate?.call(1);
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Route List
          if (shopProvider.isLoading && shopProvider.shops.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (shopProvider.shops.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No shops found for this route.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shop = shopProvider.shops[index];
                    final isVisited = visitProvider.repVisits.any(
                      (v) =>
                          v.shopId == shop.shopId &&
                          v.timestamp.isAfter(startOfDay),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShopDetailScreen(shop: shop),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(
                          shop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          shop.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isVisited
                                    ? Colors.green[700]
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isVisited ? 'Visited' : 'Pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: shopProvider.shops.length > 5
                      ? 5
                      : shopProvider.shops.length,
                ),
              ),
            ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ), // Space for button
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              onNavigate?.call(1);
            },
            icon: const Icon(Icons.near_me, color: Colors.white),
            label: const Text(
              'Start Route',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(221, 102, 30, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
