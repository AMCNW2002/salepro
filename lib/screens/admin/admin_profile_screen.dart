import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Admin User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'admin@salepro.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Company Details'),
              subtitle: Text(user?.shopName ?? 'SalePro Inc.'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const Divider(),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Logout',
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: TextEditingController(),
              labelText: 'Current Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(),
              labelText: 'New Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(),
              labelText: 'Confirm New Password',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
