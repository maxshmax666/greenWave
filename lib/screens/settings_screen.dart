import 'package:flutter/material.dart';
import '../env.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lang = 'en';
  final _urlCtrl = TextEditingController(text: Env.supabaseUrl);
  final _keyCtrl = TextEditingController(text: Env.supabaseAnonKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            value: themeMode.value == ThemeMode.dark,
            onChanged: (v) => setState(
                () => themeMode.value = v ? ThemeMode.dark : ThemeMode.light),
          ),
          DropdownButtonFormField<String>(
            value: _lang,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ru', child: Text('Русский')),
            ],
            onChanged: (v) => setState(() => _lang = v ?? 'en'),
            decoration: const InputDecoration(labelText: 'Language'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(labelText: 'Supabase URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            decoration: const InputDecoration(labelText: 'Supabase Key'),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
