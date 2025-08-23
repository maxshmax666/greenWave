import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/light_cycle.dart';

class CyclesRepo {
  CyclesRepo(this._client);
  final SupabaseClient _client;

  Future<List<LightCycle>> list({
    int? lightId,
    String? dir,
    DateTime? from,
    DateTime? to,
  }) async {
    final q = _client.from('light_cycles').select();
    if (lightId != null) q.eq('light_id', lightId);
    if (dir != null) q.eq('dir', dir);
    if (from != null) q.gte('start_ts', from.toUtc().toIso8601String());
    if (to != null) q.lte('start_ts', to.toUtc().toIso8601String());
    final res = await q.order('start_ts');
    return (res as List)
        .map((e) => LightCycle.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<LightCycle?> get(int id) async {
    final res = await _client
        .from('light_cycles')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res == null
        ? null
        : LightCycle.fromMap(res as Map<String, dynamic>);
  }

  Future<LightCycle> insert(LightCycle cycle, {required String uid}) async {
    final res = await _client
        .from('light_cycles')
        .insert(cycle.toInsert(uid: uid))
        .select()
        .single();
    return LightCycle.fromMap(res as Map<String, dynamic>);
  }

  Future<LightCycle> update(LightCycle cycle) async {
    final data = {
      'light_id': cycle.lightId,
      'phase': cycle.phase,
      'dir': cycle.dir,
      'start_ts': cycle.startTs.toUtc().toIso8601String(),
      'end_ts': cycle.endTs.toUtc().toIso8601String(),
      'source': cycle.source,
      'inserted_via': cycle.insertedVia,
      'confidence': cycle.confidence,
      'note': cycle.note,
    };
    final res = await _client
        .from('light_cycles')
        .update(data)
        .eq('id', cycle.id)
        .select()
        .single();
    return LightCycle.fromMap(res as Map<String, dynamic>);
  }
}
