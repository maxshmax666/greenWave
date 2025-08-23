import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

final _sb = Supabase.instance.client;

class SyncService {
  static Future<int?> upsertLight(TrafficLight t) async {
    final r = await _sb.from('lights').upsert({'lat':t.lat,'lon':t.lon}, onConflict:'lat,lon').select('id').single();
    return r['id'] as int?;
  }

  static Future<void> pushSamples(List<PhaseSample> xs, {String? deviceId}) async {
    if(xs.isEmpty) return;
    final rows = xs.map((s)=>{
      'light_id': s.lightId,
      'phase': s.phase.index,
      'ts': s.ts.toIso8601String(),
      'confidence': s.confidence,
      'device_id': deviceId,
    }).toList();
    await _sb.from('samples').insert(rows);
  }
}
