import 'package:latlong2/latlong.dart';

class SnappedLight {
  final Map<String, dynamic> light;

  /// Расстояние вдоль маршрута до проекции точки (метры)
  final double alongMeters;

  /// Поперечное отклонение от маршрута до ближайшей проекции (метры)
  final double offsetMeters;

  const SnappedLight({
    required this.light,
    required this.alongMeters,
    required this.offsetMeters,
  });
}

class SnapUtils {
  /// Привязывает светофоры [lights] к полилинии [route].
  /// Оставляет только те, что ближе [toleranceMeters] к линии маршрута,
  /// и сортирует по возрастанию расстояния вдоль маршрута.
  static List<SnappedLight> snapLights(
    List<Map<String, dynamic>> lights,
    List<LatLng> route, {
    double toleranceMeters = 40, // ⚠️ без лишней запятой
  }) {
    if (route.length < 2) return const [];

    final dist = const Distance();
    final res = <SnappedLight>[];

    for (final l in lights) {
      final lat = (l['lat'] as num?)?.toDouble();
      final lon = (l['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;

      final p = LatLng(lat, lon);

      double bestOffset = double.infinity; // поперечная
      double bestAlong = 0;                // вдоль маршрута
      double traveled = 0;                 // накопленная длина

      for (int i = 0; i < route.length - 1; i++) {
        final a = route[i];
        final b = route[i + 1];
        final segLen = dist(a, b); // в метрах

        // t — параметр проекции на отрезок AB в "гео‑координатах" (линейная аппроксимация ок на малых отрезках)
        final t = _projectT(p, a, b);

        // Проекция точки на сегмент (линейная интерполяция lat/lon)
        final proj = LatLng(
          a.latitude + (b.latitude - a.latitude) * t,
          a.longitude + (b.longitude - a.longitude) * t,
        );

        final off = dist(p, proj);
        if (off < bestOffset) {
          bestOffset = off;
          bestAlong = traveled + segLen * t;
        }

        traveled += segLen;
      }

      if (bestOffset <= toleranceMeters) {
        res.add(SnappedLight(
          light: l,
          alongMeters: bestAlong,
          offsetMeters: bestOffset,
        ));
      }
    }

    res.sort((a, b) => a.alongMeters.compareTo(b.alongMeters));
    return res;
  }

  /// Проекция точки P на отрезок AB в параметрах [0..1] (в плоской аппроксимации по lat/lon).
  static double _projectT(LatLng p, LatLng a, LatLng b) {
    final ax = a.latitude,  ay = a.longitude;
    final bx = b.latitude,  by = b.longitude;
    final px = p.latitude,  py = p.longitude;

    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) return 0.0;

    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    // clamp в пределах отрезка
    return t.clamp(0.0, 1.0);
  }
}
