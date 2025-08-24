/// Represents a single phase of a traffic light.
class LightCycle {
  final int lightId;
  final String phase; // green, yellow, red
  final DateTime startTs;
  final DateTime endTs;

  LightCycle({
    required this.lightId,
    required this.phase,
    required this.startTs,
    required this.endTs,
  });
}
