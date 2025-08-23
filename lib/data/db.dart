import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDb {
  static final AppDb _i = AppDb._();
  AppDb._();
  factory AppDb()=>_i;

  Database? _db;
  Future<Database> get db async {
    if(_db!=null) return _db!;
    final dir=await getApplicationDocumentsDirectory();
    final path=p.join(dir.path,'greenwave.sqlite');
    _db=await openDatabase(path, version:1, onCreate:(db,v) async {
      await db.execute('CREATE TABLE lights(id INTEGER PRIMARY KEY AUTOINCREMENT, lat REAL, lon REAL)');
      await db.execute('CREATE TABLE samples(id INTEGER PRIMARY KEY AUTOINCREMENT, light_id INT, phase INT, ts TEXT, confidence REAL)');
    });
    return _db!;
  }

  Future<int> addLight(TrafficLight t) async => (await db).insert('lights', t.toMap()..remove('id'));
  Future<List<TrafficLight>> getLights() async {
    final res = await (await db).query('lights', orderBy:'id DESC');
    return res.map((m)=>TrafficLight.fromMap(m)).toList();
  }

  Future<int> addSample(PhaseSample s) async => (await db).insert('samples', s.toMap()..remove('id'));
  Future<List<PhaseSample>> samplesByLight(int lightId) async {
    final res = await (await db).query('samples', where:'light_id=?', whereArgs:[lightId], orderBy:'ts ASC');
    return res.map((m)=>PhaseSample(
      id:m['id'] as int?, lightId:m['light_id'] as int, phase: Phase.values[m['phase'] as int],
      ts: DateTime.parse(m['ts'] as String), confidence:(m['confidence'] as num?)?.toDouble()
    )).toList();
  }
}
