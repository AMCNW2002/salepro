import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  final List<String> _supportedLanguages = const [
    'English',
    'Sinhala',
    'Tamil',
    'Spanish',
    'French',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentLanguage = settings.language;

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _supportedLanguages.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = _supportedLanguages[index];
          final isSelected = lang == currentLanguage;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              lang,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFFE53935) : null,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFFE53935))
                : const Icon(Icons.circle_outlined, color: Colors.grey),
            onTap: () {
              context.read<SettingsProvider>().setLanguage(lang);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language changed to $lang')),
              );
            },
          );
        },
      ),
    );
  }
}
