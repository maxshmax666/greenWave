class Light {
  final int id;
  final String? name;
  final double lat, lon;

  Light({
    required this.id,
    this.name,
    required this.lat,
    required this.lon,
  });

  factory Light.fromMap(Map<String, dynamic> m) => Light(
        id: m['id'] as int,
        name: m['name'] as String?,
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
      );

  Map<String, dynamic> toInsert(String uid) => {
        'name': name,
        'lat': lat,
        'lon': lon,
        'created_by': uid,
      };
}
