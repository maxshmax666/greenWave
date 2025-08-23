import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../env.dart';
import '../main.dart';
import '../shared/constants/app_colors.dart';

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
 
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.darkTheme),
            value: themeMode.value == ThemeMode.dark,
            onChanged: (v) => setState(
                () => themeMode.value = v ? ThemeMode.dark : ThemeMode.light),
          ),

      final l = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(title: Text(l.settings)),
        body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            SwitchListTile(
              title: Text(l.darkTheme),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) => setState(
                  () => themeMode.value = v ? ThemeMode.dark : ThemeMode.light),
            ),
 
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final c in AppColors.themeColors)
                GestureDetector(
                  onTap: () async {
                    setState(() => themeColor.value = c);
                    final prefs = await SharedPreferences.getInstance();
 
                    await prefs.setInt(
                        'primary_color', AppColors.themeColors.indexOf(c));

                    await prefs.setInt('primary_color', AppColors.themeColors.indexOf(c));
 
                  },
                  child: CircleAvatar(
                    backgroundColor: c,
                    child: themeColor.value == c
                        ? const Icon(Icons.check, color: AppColors.white)
                        : null,
                  ),
                ),
            ],
          ),
 
          DropdownButtonFormField<String>(
            value: _lang,
            items: [
              DropdownMenuItem(value: 'en', child: Text(l10n.english)),
              DropdownMenuItem(value: 'ru', child: Text(l10n.russian)),
            ],
            onChanged: (v) => setState(() => _lang = v ?? 'en'),
            decoration: InputDecoration(labelText: l10n.language),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlCtrl,
            decoration: InputDecoration(labelText: l10n.supabaseUrl),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            decoration: InputDecoration(labelText: l10n.supabaseKey),
            obscureText: true,
          ),

            DropdownButtonFormField<String>(
              value: _lang,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ru', child: const Text('Русский')),
              ],
              onChanged: (v) => setState(() => _lang = v ?? 'en'),
              decoration:
                  InputDecoration(labelText: l.language, hintText: l.language),
            ),
          const SizedBox(height: 16),
            TextField(
              controller: _urlCtrl,
              decoration: InputDecoration(
                labelText: l.supabaseUrl,
                hintText: l.supabaseUrl,
              ),
            ),
          const SizedBox(height: 12),
            TextField(
              controller: _keyCtrl,
              decoration: InputDecoration(
                labelText: l.supabaseKey,
                hintText: l.supabaseKey,
              ),
              obscureText: true,
            ),
 
        ],
      ),
    );
  }
}
