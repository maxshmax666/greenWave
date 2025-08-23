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
