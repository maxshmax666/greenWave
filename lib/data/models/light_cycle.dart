class LightCycle {
  final int id;
  final int lightId;
  final String phase; // 'red'|'green'|'yellow'
  final DateTime startTs;
  final DateTime endTs;
  final String source;

  LightCycle({
    required this.id,
    required this.lightId,
    required this.phase,
    required this.startTs,
    required this.endTs,
    this.source = 'camera',
  });

  factory LightCycle.fromMap(Map<String, dynamic> m) => LightCycle(
        id: m['id'] as int,
        lightId: m['light_id'] as int,
        phase: m['phase'] as String,
        startTs: DateTime.parse(m['start_ts'] as String),
        endTs: DateTime.parse(m['end_ts'] as String),
        source: m['source'] as String? ?? 'camera',
      );

  Map<String, dynamic> toInsert({required String uid}) => {
        'light_id': lightId,
        'phase': phase,
        'start_ts': startTs.toUtc().toIso8601String(),
        'end_ts': endTs.toUtc().toIso8601String(),
        'source': source,
        'created_by': uid,
      };
}
