import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(MaterialColor seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  static ThemeData dark(MaterialColor seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }
}
