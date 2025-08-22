import 'package:latlong2/latlong.dart';
import 'snap_utils.dart';

class SpeedAdvice {
  final bool hasLights;
  final double? speedKmh;
  final int? etaSec;
  SpeedAdvice.noLights()
      : hasLights = false,
        speedKmh = null,
        etaSec = null;
  SpeedAdvice({required this.speedKmh, required this.etaSec})
      : hasLights = true;
}

class SpeedAdvisor {
  static const int minKmh = 25;
  static const int maxKmh = 70;
  static const int stepKmh = 5;
  static const int lookAhead = 3;

  static SpeedAdvice advise(
      {required LatLng pos,
      required List<LatLng> route,
      required List<Map<String, dynamic>> lights}) {
    final progress = SnapUtils.snapPoint(pos, route);
    if (progress == null) return SpeedAdvice.noLights();
    final snapped = SnapUtils.snapLights(lights, route);
    final ahead = snapped.where((e) => e.alongMeters > progress).toList();
    if (ahead.isEmpty) return SpeedAdvice.noLights();
    final consider = ahead.take(lookAhead).toList();
    int bestScore = -10000;
    double bestKmh = minKmh.toDouble();
    for (int kmh = minKmh; kmh <= maxKmh; kmh += stepKmh) {
      final v = kmh / 3.6;
      int score = 0;
      for (final sl in consider) {
        final dist = sl.alongMeters - progress;
        final t = dist / v;
        final ph = _phaseAt(sl.light, t);
        if (ph == _Phase.green) score += 2;
        else if (ph == _Phase.yellow) score += 0;
        else score -= 2;
      }
      if (score > bestScore) {
        bestScore = score;
        bestKmh = kmh.toDouble();
      }
    }
    final vBest = bestKmh / 3.6;
    final eta = ((consider.first.alongMeters - progress) / vBest).round();
    return SpeedAdvice(speedKmh: bestKmh, etaSec: eta);
  }

  static _Phase _phaseAt(Map<String, dynamic> l, double etaSeconds) {
    final red = (l['red_sec'] as int?) ?? 0;
    final green = (l['green_sec'] as int?) ?? 0;
    final yellow = (l['yellow_sec'] as int?) ?? 0;
    final total = red + green + yellow;
    final startStr = l['cycle_start_at'] as String?;
    if (total <= 0 || startStr == null) return _Phase.red;
    final start = DateTime.parse(startStr).toUtc();
    final now = DateTime.now().toUtc().add(Duration(seconds: etaSeconds.round()));
    int s = now.difference(start).inSeconds % total;
    if (s < 0) s += total;
    if (s < red) return _Phase.red;
    if (s < red + green) return _Phase.green;
    return _Phase.yellow;
  }
}

enum _Phase { red, yellow, green }
