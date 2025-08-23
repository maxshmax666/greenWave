class Light {
  final int id;
  final String? name;
  final String? intersectionName;
  final double lat, lon;
  final List<String> tags;
  final int? bearingMain;
  final int? bearingSecondary;
  Light({
    required this.id,
    this.name,
    this.intersectionName,
    required this.lat,
    required this.lon,
    this.tags = const [],
    this.bearingMain,
    this.bearingSecondary,
  });

  factory Light.fromMap(Map<String, dynamic> m) => Light(
    id: m['id'] as int,
    name: m['name'] as String?,
    intersectionName: m['intersection_name'] as String?,
    lat: (m['lat'] as num).toDouble(),
    lon: (m['lon'] as num).toDouble(),
    tags: (m['tags'] as List?)?.cast<String>() ?? const [],
    bearingMain: m['bearing_main'] as int?,
    bearingSecondary: m['bearing_secondary'] as int?,
  );

  Map<String, dynamic> toInsert(String uid) => {
    'name': name,
    'intersection_name': intersectionName,
    'lat': lat,
    'lon': lon,
    'tags': tags,
    'bearing_main': bearingMain,
    'bearing_secondary': bearingSecondary,
    'created_by': uid,
  };
}
