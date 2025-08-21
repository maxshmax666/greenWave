enum Phase { red, yellow, green }

class TrafficLight {
  int? id;
  double lat, lon;
  TrafficLight({this.id, required this.lat, required this.lon});
  Map<String, dynamic> toMap()=>{'id':id,'lat':lat,'lon':lon};
  static TrafficLight fromMap(Map<String,Object?> m)=>TrafficLight(
    id:m['id'] as int?, lat:(m['lat'] as num).toDouble(), lon:(m['lon'] as num).toDouble()
  );
}

class PhaseSample {
  int? id;
  int lightId;
  Phase phase;
  DateTime ts;
  double? confidence;
  PhaseSample({this.id, required this.lightId, required this.phase, required this.ts, this.confidence});
  Map<String,dynamic> toMap()=>{'id':id,'light_id':lightId,'phase':phase.index,'ts':ts.toIso8601String(),'confidence':confidence};
}
