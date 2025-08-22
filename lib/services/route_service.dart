import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart';

/// Calls OSRM public demo service to fetch route between two points.
class RouteService {
  static Future<List<LatLng>> getRoute(LatLng from, LatLng to) async {
    final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson');
    final req = await HttpClient().getUrl(uri);
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw Exception('OSRM status ${resp.statusCode}');
    }
    final body = await resp.transform(utf8.decoder).join();
    final data = jsonDecode(body);
    final coords = data['routes'][0]['geometry']['coordinates'] as List;
    return coords
        .map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }
}
