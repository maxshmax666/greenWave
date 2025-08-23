import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/light.dart';

class LightsRepo {
  LightsRepo(this._client);
  final SupabaseClient _client;

  Future<List<Light>> list() async {
    final res = await _client.from('lights').select().order('id');
    return (res as List)
        .map((e) => Light.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Light?> get(int id) async {
    final res =
        await _client.from('lights').select().eq('id', id).maybeSingle();
    return res == null ? null : Light.fromMap(res as Map<String, dynamic>);
  }

  Future<Light> insert(Light light, {required String uid}) async {
    final res = await _client
        .from('lights')
        .insert(light.toInsert(uid))
        .select()
        .single();
    return Light.fromMap(res as Map<String, dynamic>);
  }

  Future<Light> update(Light light) async {
    final data = {
      'name': light.name,
      'intersection_name': light.intersectionName,
      'lat': light.lat,
      'lon': light.lon,
      'tags': light.tags,
      'bearing_main': light.bearingMain,
      'bearing_secondary': light.bearingSecondary,
    };
    final res = await _client
        .from('lights')
        .update(data)
        .eq('id', light.id)
        .select()
        .single();
    return Light.fromMap(res as Map<String, dynamic>);
  }
}
