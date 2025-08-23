import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';
import '../main.dart';
import '../theme_colors.dart';

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
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveThemeMode(ThemeMode m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', m == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Светлая/тёмная тема
          SwitchListTile(
            title: const Text('Dark theme'),
            value: themeMode.value == ThemeMode.dark,
            onChanged: (v) async {
              final m = v ? ThemeMode.dark : ThemeMode.light;
              themeMode.value = m;
              await _saveThemeMode(m);
              setState(() {});
            },
          ),

          const SizedBox(height: 12),

          // Выбор seed‑палитры с сохранением индекса
          ValueListenableBuilder<int>(
            valueListenable: themeColorIndex,
            builder: (context, idx, _) => Row(
              children: [
                for (int i = 0; i < seedColors.length; i++)
                  GestureDetector(
                    onTap: () async {
                      themeColorIndex.value = i;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('colorIndex', i);
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: seedColors[i],
                        shape: BoxShape.circle,
                        border: idx == i
                            ? Border.all(width: 3, color: Colors.black)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Прямой выбор основного цвета с сохранением индекса
          Wrap(
            spacing: 8,
            children: [
              for (final c in themeColors)
                GestureDetector(
                  onTap: () async {
                    setState(() => themeColor.value = c);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('primary_color', themeColors.indexOf(c));
                  },
                  child: CircleAvatar(
                    backgroundColor: c,
                    child: themeColor.value == c
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Язык интерфейса (пока локально)
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

          // Supabase настройки (для отладки)
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
