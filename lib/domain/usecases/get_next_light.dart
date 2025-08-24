import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../models/light.dart';

/// Use case that determines the next traffic light along the user's route.
///
/// In this simplified version the implementation is left as a stub and should
/// be replaced with real logic once route data is available.
class GetNextLight {
  Future<Light?> call(Position user, Polyline route) async {
    // TODO: Implement real calculation based on user's position and route.
    return null;
  }
}
