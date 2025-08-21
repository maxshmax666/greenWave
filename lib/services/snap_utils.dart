import 'package:latlong2/latlong.dart';

class SnappedLight {
  final Map<String, dynamic> light;
  final double distance;
  SnappedLight({required this.light, required this.distance});
}

class SnapUtils {
  static List<SnappedLight> snapLights(
    List<Map<String, dynamic>> lights,
    List<LatLng> route,
    {double toleranceMeters = 40},
  ) {
    final dist = const Distance();
    final res = <SnappedLight>[];
    for (final l in lights) {
      final lat = (l['lat'] as num?)?.toDouble();
      final lon = (l['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final p = LatLng(lat, lon);
      double best = double.infinity;
      double bestAlong = 0;
      double traveled = 0;
      for (int i = 0; i < route.length - 1; i++) {
        final a = route[i];
        final b = route[i + 1];
        final segLen = dist(a, b);
        final t = _projectT(p, a, b);
        final proj = LatLng(
            a.latitude + (b.latitude - a.latitude) * t,
            a.longitude + (b.longitude - a.longitude) * t);
        final d = dist(p, proj);
        if (d < best) {
          best = d;
          bestAlong = traveled + segLen * t;
        }
        traveled += segLen;
      }
      if (best <= toleranceMeters) {
        res.add(SnappedLight(light: l, distance: bestAlong));
      }
    }
    res.sort((a, b) => a.distance.compareTo(b.distance));
    return res;
  }

  static double _projectT(LatLng p, LatLng a, LatLng b) {
    final ax = a.latitude;
    final ay = a.longitude;
    final bx = b.latitude;
    final by = b.longitude;
    final px = p.latitude;
    final py = p.longitude;
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) return 0;
    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    return t.clamp(0.0, 1.0);
  }
}
