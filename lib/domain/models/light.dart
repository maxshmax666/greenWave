/// Domain model representing a traffic light.
class Light {
  final int id;
  final String name;
  final double lat;
  final double lon;

  Light({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });
}
