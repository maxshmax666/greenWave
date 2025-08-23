import 'package:flutter/material.dart';

/// Centralized app theme with shared paddings, radii and fonts.
class AppTheme {
  AppTheme._();

  /// Default border radius used across the app.
  static const BorderRadiusGeometry radius = BorderRadius.all(Radius.circular(12));

  /// Default padding for widgets such as buttons.
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
        headlineLarge: base.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  /// Light theme configuration.
  static ThemeData light(MaterialColor color) {
    final scheme = ColorScheme.fromSeed(seedColor: color);
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: scheme,
      textTheme: _textTheme(base.textTheme),
      useMaterial3: true,
    );
  }

  /// Dark theme configuration.
  static ThemeData dark(MaterialColor color) {
    final scheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: scheme,
      textTheme: _textTheme(base.textTheme),
      useMaterial3: true,
    );
  }
}
