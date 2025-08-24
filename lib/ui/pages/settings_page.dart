import 'package:flutter/material.dart';

import '../../main.dart';
import '../../shared/settings.dart';

/// Settings page allowing customization of theme and speed advisor options.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _dark;
  late bool _showLightCard;
  late double _vMin;
  late double _vMax;

  @override
  void initState() {
    super.initState();
    _dark = themeMode.value == ThemeMode.dark;
    _showLightCard = Settings.showLightCard;
    _vMin = Settings.vMin;
    _vMax = Settings.vMax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: _dark,
            onChanged: (v) {
              setState(() => _dark = v);
              themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          SwitchListTile(
            title: const Text('Показывать карточку светофора'),
            value: _showLightCard,
            onChanged: (v) {
              setState(() => _showLightCard = v);
              Settings.showLightCard = v;
            },
          ),
          const SizedBox(height: 16),
          Text('Минимальная скорость: ${_vMin.toStringAsFixed(0)} км/ч'),
          Slider(
            min: 10,
            max: 60,
            value: _vMin,
            onChanged: (v) => setState(() => _vMin = v),
            onChangeEnd: (v) => Settings.vMin = v,
          ),
          Text('Максимальная скорость: ${_vMax.toStringAsFixed(0)} км/ч'),
          Slider(
            min: 40,
            max: 120,
            value: _vMax,
            onChanged: (v) => setState(() => _vMax = v),
            onChangeEnd: (v) => Settings.vMax = v,
          ),
        ],
      ),
    );
  }
}
