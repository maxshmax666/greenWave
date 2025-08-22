import 'package:latlong2/latlong.dart';

final Distance _dist = const Distance();

class SnappedLight {
  final Map<String, dynamic> light;
  final double alongMeters;
  SnappedLight({required this.light, required this.alongMeters});
}

class SnapUtils {
  static List<SnappedLight> snapLights(List<Map<String, dynamic>> lights,
      List<LatLng> route,
      {double toleranceMeters = 40}) {
    final cum = _cumulative(route);
    final res = <SnappedLight>[];
    for (final l in lights) {
      final lat = (l['lat'] as num?)?.toDouble();
      final lon = (l['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final p = LatLng(lat, lon);
      double best = double.infinity;
      int bestIdx = -1;
      for (int i = 0; i < route.length; i++) {
        final d = _dist(p, route[i]);
        if (d < best) {
          best = d;
          bestIdx = i;
        }
      }
      if (bestIdx >= 0 && best <= toleranceMeters) {
        res.add(SnappedLight(light: l, alongMeters: cum[bestIdx]));
      }
    }
    res.sort((a, b) => a.alongMeters.compareTo(b.alongMeters));
    return res;
  }

  static double? snapPoint(LatLng p, List<LatLng> route,
      {double toleranceMeters = 40}) {
    final cum = _cumulative(route);
    double best = double.infinity;
    int bestIdx = -1;
    for (int i = 0; i < route.length; i++) {
      final d = _dist(p, route[i]);
      if (d < best) {
        best = d;
        bestIdx = i;
      }
    }
    if (bestIdx < 0 || best > toleranceMeters) return null;
    return cum[bestIdx];
  }

  static List<double> _cumulative(List<LatLng> pts) {
    final c = <double>[0];
    for (int i = 1; i < pts.length; i++) {
      c.add(c.last + _dist(pts[i - 1], pts[i]));
    }
    return c;
  }
}
