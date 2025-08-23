import 'package:flutter/material.dart';

 
/// Builds theme data for the application.
class AppTheme {
  AppTheme._();

  static ThemeData light(MaterialColor color) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: color),
        useMaterial3: true,
      );

  static ThemeData dark(MaterialColor color) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

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
