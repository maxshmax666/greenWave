import 'package:flutter/material.dart';

/// Helpers for constructing app themes.
class AppTheme {
  static ThemeData light(MaterialColor color) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: color),
      useMaterial3: true,
    );
  }

  static ThemeData dark(MaterialColor color) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
