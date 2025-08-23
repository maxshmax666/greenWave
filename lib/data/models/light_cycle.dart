class LightCycle {
  final int id;
  final int lightId;
  final String phase; // 'red'|'green'|'yellow'
  final String dir;   // 'main'|'secondary'|'ped'
  final DateTime startTs;
  final DateTime endTs;
  final String source;
  final String insertedVia; // 'camera'|'manual'|'import'|'whatif'
  final double confidence;
  final String? note;

  LightCycle({
    required this.id,
    required this.lightId,
    required this.phase,
    required this.dir,
    required this.startTs,
    required this.endTs,
    this.source = 'camera',
    this.insertedVia = 'camera',
    this.confidence = 1.0,
    this.note,
  });

  factory LightCycle.fromMap(Map<String, dynamic> m) => LightCycle(
    id: m['id'] as int,
    lightId: m['light_id'] as int,
    phase: m['phase'] as String,
    dir: m['dir'] as String? ?? 'main',
    startTs: DateTime.parse(m['start_ts'] as String),
    endTs: DateTime.parse(m['end_ts'] as String),
    source: m['source'] as String? ?? 'camera',
    insertedVia: m['inserted_via'] as String? ?? 'camera',
    confidence: (m['confidence'] as num?)?.toDouble() ?? 1.0,
    note: m['note'] as String?,
  );

  Map<String, dynamic> toInsert({
    required String uid,
  }) => {
    'light_id': lightId,
    'phase': phase,
    'dir': dir,
    'start_ts': startTs.toUtc().toIso8601String(),
    'end_ts': endTs.toUtc().toIso8601String(),
    'source': source,
    'inserted_via': insertedVia,
    'confidence': confidence,
    'note': note,
    'created_by': uid,
  };
}
