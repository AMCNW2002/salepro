import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_transition_switcher.dart';
import '../admin/admin_routes_screen.dart';
import '../admin/admin_shops_screen.dart';
import '../admin/admin_dashboard_home.dart';
import '../admin/admin_products_screen.dart';
import '../admin/admin_reports_screen.dart';
import '../admin/admin_profile_screen.dart';
import '../settings/app_settings_screen.dart';
import '../settings/language_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/about_app_screen.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardHome(),
    const AdminRoutesScreen(),
    const AdminShopsScreen(),
    const AdminProductsScreen(),
    const AdminReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserModel;
    return Scaffold(
      drawer: _currentIndex == 0
          ? Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: Drawer(
                backgroundColor: const Color(0xFFF8F9FA),
                surfaceTintColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 60,
                        bottom: 30,
                        left: 24,
                        right: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD32F2F), Color(0xFFEF5350), // Blue 500
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
                          ),
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
                                    : 'A',
                                style: const TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.name ?? 'Administrator',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user?.email ?? 'Admin Team',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade700,
                              ),
                              title: Text(
                                'My Profile',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Icon(
                                Icons.settings_outlined,
                                color: Colors.grey.shade700,
                              ),
                              title: Text(
                                'Settings',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 54,
                                    right: 16,
                                  ),
                                  leading: Icon(
                                    Icons.tune,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  title: Text(
                                    'App Settings',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AppSettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 54,
                                    right: 16,
                                  ),
                                  leading: Icon(
                                    Icons.language,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  title: Text(
                                    'Language',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LanguageScreen(),
                                      ),
                                    );
                                  },
                                ),
                                Consumer<SettingsProvider>(
                                  builder: (context, settings, child) {
                                    return ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 54,
                                        right: 16,
                                      ),
                                      leading: Icon(
                                        Icons.dark_mode_outlined,
                                        size: 20,
                                        color: Colors.grey.shade600,
                                      ),
                                      title: Text(
                                        'Dark Mode',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Switch(
                                        value: settings.isDarkMode,
                                        onChanged: (val) {
                                          settings.toggleTheme(val);
                                        },
                                        activeColor: const Color.fromARGB(
                                          255,
                                          30,
                                          58,
                                          138,
                                        ),
                                      ),
                                      onTap: () {
                                        settings.toggleTheme(
                                          !settings.isDarkMode,
                                        );
                                      },
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 54,
                                    right: 16,
                                  ),
                                  leading: Icon(
                                    Icons.help_outline,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  title: Text(
                                    'Help & Support',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HelpSupportScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 54,
                                    right: 16,
                                  ),
                                  leading: Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  title: Text(
                                    'About App',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AboutAppScreen(),
                                      ),
                                    );
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
                            margin: const EdgeInsets.only(
                              top: 8,
                              bottom: 24,
                              left: 8,
                              right: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade500,
                                  Colors.red.shade800,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade300.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                  context.read<AuthProvider>().logout();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.power_settings_new,
                                          color: Colors.white,
                                          size: 22,
                                        ),
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
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              title: const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    if (user != null) {
                      _showNotificationsSheet(context, user.uid);
                    }
                  },
                ),
              ],
            )
          : (_currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3 || _currentIndex == 4)
              ? null // Hide default AppBar for Routes, Shops, Products, and Reports screens to show custom header
              : AppBar(title: const Text('Admin Dashboard')),
      body: PageTransitionSwitcher(
        index: _currentIndex,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Routes',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Shops',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
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
