import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../env.dart';

class RouteService {
  /// Requests a route from OpenRouteService between [start] and [end].
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end,
      {String profile = 'driving-car'}) async {
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/$profile?api_key=${Env.orsApiKey}&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}&geometry_format=geojson');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('ORS ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>?;
    if (features == null || features.isEmpty) {
      throw Exception('No routes');
    }
    final coords =
        (features.first['geometry']['coordinates'] as List<dynamic>).cast<List<dynamic>>();
    return coords
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }
}
