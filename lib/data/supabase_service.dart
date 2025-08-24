import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/light.dart';
import '../domain/models/light_cycle.dart';

/// Simple wrapper around the Supabase client used to fetch traffic light data.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns the next [Light] on the given [route] ahead of the [user] position.
  /// The implementation here is a placeholder and should be replaced with
  /// proper route snapping logic.
  Future<Light?> getNextLightOnRoute(Position user, Polyline route) async {
    // TODO: Implement real logic to fetch the next light along the route.
    return null;
  }

  /// Fetches the current phase for the light with [lightId].
  /// Uses table `light_cycles` with fields: light_id, phase, start_ts, end_ts.
  Future<LightCycle?> getCurrentPhase(int lightId) async {
    // TODO: Implement query to Supabase once backend is ready.
    return null;
  }
}
