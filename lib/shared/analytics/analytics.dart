import 'package:flutter/foundation.dart';

 
/// Interface for analytics services.
abstract class Analytics {
  /// Logs an analytics [event] with optional [params].
  void logEvent(String event, [Map<String, dynamic>? params]);
}

/// Simple analytics implementation that prints events to debug output.
class DummyAnalytics implements Analytics {
  @override
  void logEvent(String event, [Map<String, dynamic>? params]) {
    debugPrint('Analytics event: ' + event + (params == null ? '' : ' ' + params.toString()));
  }
}

/// Global analytics instance used by the app.
final analytics = DummyAnalytics();

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
 
