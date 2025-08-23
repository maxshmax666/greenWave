import 'dart:math';

/// Suggests a target speed to reach one of the upcoming green windows.
double adviseSpeedKmh({
  required double distanceM,
  required double currentKmh,
  required List<({double tStart, double tEnd})> windows,
  double limitKmh = 70,
  double dtSec = 1.0,
}) {
  const minKmh = 25.0; // search range
  const minRollKmh = 20.0;
  final maxKmh = min(limitKmh, 70.0);

  // physical limits (approx.):
  const accelLimit = 7.2; // km/h per second (~2 m/s^2)
  const decelLimit = 10.8; // km/h per second (~3 m/s^2)
  const emaAlpha = 0.5;
  const deadband = 0.5;

  double? target;
  for (final w in windows) {
    if (w.tEnd <= 0) continue;
    final vMin = distanceM / w.tEnd * 3.6; // km/h
    final vMax = distanceM / w.tStart * 3.6; // km/h
    final low = max(minKmh, vMin);
    final high = min(maxKmh, vMax);
    if (low <= high) {
      if (currentKmh < low) {
        target = low;
      } else if (currentKmh > high) {
        target = high;
      } else {
        target = currentKmh;
      }
      break;
    }
  }
  target ??= max(minKmh, min(maxKmh, currentKmh));

  var delta = target - currentKmh;
  if (delta > 0) {
    delta = min(delta, accelLimit * dtSec);
  } else {
    delta = max(delta, -decelLimit * dtSec);
  }
  var next = currentKmh + delta;
  // EMA smoothing
  next = emaAlpha * next + (1 - emaAlpha) * currentKmh;
  // deadband to prevent jitter
  if ((next - currentKmh).abs() < deadband) {
    next = currentKmh;
  }
  next = next.clamp(minRollKmh, maxKmh);
  return next.roundToDouble();
}
