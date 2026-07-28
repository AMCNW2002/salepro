import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Push Notifications setting saved'),
                      ),
                    );
                  },
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Receive alerts for new orders and shops.',
                  ),
                  activeColor: const Color(0xFFE53935),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: false,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location Tracking setting saved'),
                      ),
                    );
                  },
                  title: const Text(
                    'Location Tracking',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Improve route suggestions and visit logging.',
                  ),
                  activeColor: const Color(0xFFE53935),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sync over Wi-Fi only setting saved'),
                      ),
                    );
                  },
                  title: const Text(
                    'Sync Over Wi-Fi Only',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  activeColor: const Color(0xFFE53935),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Clear Local Cache',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.delete_outline, color: Colors.red),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Local cache cleared!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
