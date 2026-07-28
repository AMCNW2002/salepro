import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 48, color: Color(0xFFE53935)),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is available 24/7 to assist you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFaqItem('How do I assign a new shop?', 'You can assign a new shop from the My Shops tab by tapping the plus icon in the bottom right corner.'),
            _buildFaqItem('How do I record a payment?', 'Go to the Payments tab and tap "New Payment" to record a collection for a specific shop.'),
            _buildFaqItem('Can I use the app offline?', 'Currently, an active internet connection is required to sync data with the server, though some features are cached locally.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Contact Support'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support email client would open here.')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ),
      ],
    );
  }
}
