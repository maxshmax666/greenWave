import 'package:flutter/material.dart';
import 'package:green_wave_app/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';
import '../main.dart';
import '../shared/constants/app_colors.dart';
import '../ui/settings/car_avatar_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lang = 'en';
  final _urlCtrl = TextEditingController(text: supabaseUrl);
  final _keyCtrl = TextEditingController(text: supabaseAnonKey);
  String _units = 'kmh';
  double _speedLimit = 60;
  double _camOffset = 0;
  double _jerkStep = 1;
  final _speedCtrl = TextEditingController();
  final _offsetCtrl = TextEditingController();
  final _jerkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _units = prefs.getString('units') ?? 'kmh';
      _speedLimit = prefs.getDouble('speed_limit') ?? 60;
      _camOffset = prefs.getDouble('cam_offset') ?? 0;
      _jerkStep = prefs.getDouble('jerk_step') ?? 1;
      _speedCtrl.text = _speedLimit.toString();
      _offsetCtrl.text = _camOffset.toString();
      _jerkCtrl.text = _jerkStep.toString();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('units', _units);
    await prefs.setDouble('speed_limit', _speedLimit);
    await prefs.setDouble('cam_offset', _camOffset);
    await prefs.setDouble('jerk_step', _jerkStep);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CarAvatarTile(),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.darkTheme),
            value: themeMode.value == ThemeMode.dark,
            onChanged: (v) => setState(
              () => themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _units,
            items: const [
              DropdownMenuItem(value: 'kmh', child: Text('km/h')),
              DropdownMenuItem(value: 'mph', child: Text('mph')),
            ],
            onChanged: (v) {
              setState(() => _units = v ?? 'kmh');
              _savePrefs();
            },
            decoration: InputDecoration(labelText: l10n.unitsKmh),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speedCtrl,
            decoration: InputDecoration(labelText: l10n.roadSpeedLimit),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _speedLimit = double.tryParse(v) ?? _speedLimit;
              _savePrefs();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _offsetCtrl,
            decoration: InputDecoration(labelText: l10n.cameraOffset),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _camOffset = double.tryParse(v) ?? _camOffset;
              _savePrefs();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jerkCtrl,
            decoration: InputDecoration(labelText: l10n.jerkStep),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _jerkStep = double.tryParse(v) ?? _jerkStep;
              _savePrefs();
            },
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
                      'primary_color',
                      AppColors.themeColors.indexOf(c),
                    );
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    _speedCtrl.dispose();
    _offsetCtrl.dispose();
    _jerkCtrl.dispose();
    super.dispose();
  }
}
