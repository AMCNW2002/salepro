import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _changePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change Password functionality coming soon!')),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserModel;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Top Red Background Curve
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  // Header Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit profile coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Identity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFD32F2F),
                            child: Text(
                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'Customer Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.shopName.isNotEmpty == true ? user!.shopName : 'My Shop',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role.toUpperCase() ?? 'CUSTOMER',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          iconColor: Colors.blue.shade600,
                          title: 'Email Address',
                          subtitle: user?.email ?? 'N/A',
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 20, color: Colors.black12),
                        _buildInfoTile(
                          icon: Icons.phone_outlined,
                          iconColor: Colors.green.shade600,
                          title: 'Phone Number',
                          subtitle: user?.phone ?? 'N/A',
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 20, color: Colors.black12),
                        _buildInfoTile(
                          icon: Icons.location_on_outlined,
                          iconColor: Colors.orange.shade600,
                          title: 'Shop Address',
                          subtitle: user?.shopAddress.isNotEmpty == true ? user!.shopAddress : 'No Address',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.lock_reset, color: Colors.grey.shade800),
                          ),
                          title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () => _changePassword(context),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 20, color: Colors.black12),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                          ),
                          title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600, fontSize: 16)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // extra padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
