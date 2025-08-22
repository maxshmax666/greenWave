import 'snap_utils.dart';

class SpeedAdvisor {
  static int? advise(List<SnappedLight> lights) {
    if (lights.isEmpty) return null;
    final now = DateTime.now().toUtc();
    int? best;
    int bestScore = -9999;
    for (int sp = 25; sp <= 70; sp += 5) {
      final v = sp / 3.6; // m/s
      int score = 0;
      for (int i = 0; i < lights.length && i < 3; i++) {
        final l = lights[i].light;
        final dist = lights[i].alongMeters;
        final arrive = now.add(Duration(seconds: (dist / v).round()));
        final ph = _phaseAt(l, arrive);
        if (ph == _Phase.green)
          score += 2;
        else if (ph == _Phase.red)
          score -= 2;
      }
      if (score > bestScore ||
          (score == bestScore && (best == null || sp < best))) {
        bestScore = score;
        best = sp;
      }
    }
    return best;
  }

  static _Phase _phaseAt(Map<String, dynamic> l, DateTime t) {
    final green = (l['green_sec'] ?? l['main_duration'] ?? 0) as int;
    final yellow = (l['yellow_sec'] ?? l['ped_duration'] ?? 0) as int;
    final red = (l['red_sec'] ?? l['side_duration'] ?? 0) as int;
    final cycle = (l['cycle_total'] as int?) ?? (green + yellow + red);
    final startStr = l['cycle_start_at'] as String?;
    final start = startStr != null ? DateTime.parse(startStr).toUtc() : null;
    if (cycle <= 0 || start == null) return _Phase.unknown;
    final offset = (l['offset_sec'] as int?) ?? 0;
    final s =
        ((t.difference(start).inSeconds + offset) % cycle + cycle) % cycle;
    if (s < green) return _Phase.green;
    if (s < green + yellow) return _Phase.yellow;
    return _Phase.red;
  }
}

enum _Phase { green, yellow, red, unknown }
