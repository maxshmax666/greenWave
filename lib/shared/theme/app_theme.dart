import 'package:flutter/material.dart';

/// Collection of theme helpers and constants used throughout the app.
class AppTheme {
  /// Default border radius used by custom widgets.
  static const BorderRadius radius = BorderRadius.all(Radius.circular(12));

  /// Default padding for controls and buttons.
  static const EdgeInsets padding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static ThemeData light(MaterialColor seed) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  static ThemeData dark(MaterialColor seed) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }
}
