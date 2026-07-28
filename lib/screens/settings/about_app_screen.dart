import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront,
                size: 80,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SalePro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'SalePro',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              '© 2026 SalePro Inc.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
