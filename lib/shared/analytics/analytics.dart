import 'package:flutter/foundation.dart';

/// Defines an interface for analytics services.
abstract class Analytics {
  /// Sends an event with an optional set of parameters.
  Future<void> logEvent(String name, [Map<String, dynamic>? params]);
}

/// A placeholder implementation that simply prints events to the console.
class DummyAnalytics implements Analytics {
  const DummyAnalytics();

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? params]) async {
    debugPrint('Analytics event: $name, params: ${params ?? {}}');
  }
}

/// Default analytics instance used throughout the app.
/// Replace with a real SDK implementation when available.
Analytics analytics = const DummyAnalytics();
