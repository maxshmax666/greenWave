import 'dart:math';

import '../data/repos/cycles_repo.dart';
import '../data/models/light_cycle.dart';

/// Service that predicts upcoming green windows for a traffic light.
class GreenWindowsService {
  GreenWindowsService(this._cycles);

  final CyclesRepo _cycles;

  /// Returns upcoming green windows relative to [now] in seconds.
  ///
  /// The service fetches last [history] green cycles for [lightId] and [dir],
  /// builds a typical period using median of intervals between cycles and uses
  /// the last observed start as an anchor. 2-3 windows ahead are returned.
  Future<List<({double tStart, double tEnd})>> fetch({
    required int lightId,
    required String dir,
    required DateTime now,
    int history = 5,
    int forward = 3,
  }) async {
    // Fetch recent cycles from repo. We request several hours back to ensure
    // enough data and then keep only the latest [history] green cycles.
    final from = now.subtract(const Duration(hours: 6));
    final cycles = await _cycles.list(
      lightId: lightId,
      dir: dir,
      from: from,
      to: now,
    );
    final greens = cycles.where((c) => c.phase.toLowerCase() == 'green').toList();
    if (greens.length < 2) return [];
    final recent = greens.sublist(max(0, greens.length - history));

    // Green duration for each cycle.
    final lengths = recent
        .map((c) => c.endTs.difference(c.startTs).inSeconds.toDouble())
        .toList();
    final tGreen = _median(lengths);

    // Period between start of subsequent green cycles.
    final intervals = <double>[];
    for (int i = 1; i < recent.length; i++) {
      intervals.add(
        recent[i]
            .startTs
            .difference(recent[i - 1].startTs)
            .inSeconds
            .toDouble(),
      );
    }
    var period = _median(intervals);
    if (period <= 0) period = intervals.isNotEmpty ? intervals.last : 60;

    // Anchor on last observed green start and project forward.
    var nextStart = recent.last.startTs;
    while (nextStart.isBefore(now)) {
      nextStart = nextStart.add(Duration(seconds: period.round()));
    }

    final res = <({double tStart, double tEnd})>[];
    for (int i = 0; i < forward; i++) {
      final s = nextStart.add(Duration(seconds: (period * i).round()));
      final e = s.add(Duration(seconds: tGreen.round()));
      res.add((
        tStart: s.difference(now).inSeconds.toDouble(),
        tEnd: e.difference(now).inSeconds.toDouble(),
      ));
    }
    return res;
  }

  double _median(List<double> v) {
    if (v.isEmpty) return 0;
    final s = [...v]..sort();
    final mid = s.length ~/ 2;
    return s.length.isOdd ? s[mid] : (s[mid - 1] + s[mid]) / 2;
  }
}
