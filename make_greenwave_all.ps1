# make_greenwave_all.ps1
# One-shot setup for GreenWave (Supabase auth + Map + Camera Recorder + Speed Advisor)
# ASCII only. Windows PowerShell.

function Get-YesNo($msg) {
  while ($true) {
    $a = Read-Host "$msg [y/n]"
    if ($a -match '^[yY]$') { return $true }
    if ($a -match '^[nN]$') { return $false }
  }
}

# --- read Supabase creds ---
$SupabaseUrl  = Read-Host "Enter SUPABASE Project URL (e.g. https://xxxxx.supabase.co)"
$SupabaseAnon = Read-Host "Enter SUPABASE anon public key"
if ([string]::IsNullOrWhiteSpace($SupabaseUrl) -or [string]::IsNullOrWhiteSpace($SupabaseAnon)) {
  throw "Supabase URL and anon key are required."
}

# --- folders ---
New-Item -ItemType Directory -Force .\lib | Out-Null
New-Item -ItemType Directory -Force .\lib\screens | Out-Null
New-Item -ItemType Directory -Force .\android\app\src\main | Out-Null

# --- pubspec.yaml ---
@'
name: green_wave_app
description: "GreenWave: Supabase + Map + Camera + Speed Advisor"
publish_to: "none"

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.6.0
  flutter_map: ^6.2.1
  latlong2: ^0.9.1
  geolocator: ^12.0.0
  permission_handler: ^11.4.0
  camera: ^0.10.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
'@ | Set-Content -Encoding UTF8 .\pubspec.yaml

# --- Android: app/build.gradle.kts ---
@'
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.green_wave_app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.green_wave_app"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter { source = "../.." }
'@ | Set-Content -Encoding UTF8 android\app\build.gradle.kts

# --- Android: proguard rules (safety, not used with minify=false) ---
@'
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
'@ | Set-Content -Encoding UTF8 android\app\proguard-rules.pro

# --- AndroidManifest.xml ---
@'
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.green_wave_app">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:name="${applicationName}"
        android:label="GreenWave"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data android:name="flutterEmbedding" android:value="2"/>
    </application>
</manifest>
'@ | Set-Content -Encoding UTF8 android\app\src\main\AndroidManifest.xml

# --- lib/main.dart (tabs + auth + todos minimal) ---
$main = @'
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/map_screen.dart';
import 'screens/cycle_recorder.dart';
import 'screens/speed_advisor.dart';

const supabaseUrl = 'REPLACE_URL';
const supabaseAnonKey = 'REPLACE_ANON';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

final supa = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenWave',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    supa.auth.onAuthStateChange.listen((_) => setState(() {}));
  }
  @override
  Widget build(BuildContext context) {
    return supa.auth.currentSession == null ? const LoginPage() : const HomeTabs();
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const MapScreen(), const TodosPage(), const CycleRecorderScreen(), const SpeedAdvisorScreen()];
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Todos'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'Advisor'),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool busy = false;

  Future<void> _submit() async {
    setState(() => busy = true);
    try {
      if (isLogin) {
        await supa.auth.signInWithPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        await supa.auth.signUp(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: busy ? null : _submit, child: Text(isLogin ? 'Sign in' : 'Create account')),
          TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? 'Create account' : 'I have an account')),
        ]),
      ),
    );
  }
}

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});
  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  RealtimeChannel? _ch;

  @override
  void initState() {
    super.initState();
    _load();
    _ch = supa
        .channel('public:todos')
        .onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'todos', callback: (_) => _load())
        .subscribe();
  }

  Future<void> _load() async {
    final u = supa.auth.currentUser;
    if (u == null) return;
    final res = await supa.from('todos').select('*').eq('user_id', u.id).order('inserted_at', ascending: false);
    setState(() => _todos = List<Map<String, dynamic>>.from(res));
  }

  Future<void> _add() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    final u = supa.auth.currentUser;
    if (u == null) return;
    await supa.from('todos').insert({'task': t, 'status': 'Not Started', 'user_id': u.id, 'inserted_at': DateTime.now().toIso8601String()});
    _controller.clear();
  }

  Future<void> _toggle(int id, String status) async {
    final next = status.toLowerCase() == 'complete' ? 'Not Started' : 'Complete';
    await supa.from('todos').update({'status': next}).eq('id', id);
  }

  Future<void> _del(int id) async {
    await supa.from('todos').delete().eq('id', id);
  }

  Future<void> _logout() async => supa.auth.signOut();

  @override
  void dispose() {
    _controller.dispose();
    if (_ch != null) supa.removeChannel(_ch!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My todos'), actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'New todo'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _add, child: const Text('Add')),
          ]),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (c, i) {
                final t = _todos[i];
                return ListTile(
                  title: Text(t['task'] ?? ''),
                  subtitle: Text('status: ${t['status']}'),
                  onTap: () => _toggle(t['id'] as int, t['status'] as String),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _del(t['id'] as int)),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
'@
$main = $main.Replace('REPLACE_URL', $SupabaseUrl).Replace('REPLACE_ANON', $SupabaseAnon)
$main | Set-Content -Encoding UTF8 .\lib\main.dart

# --- lib/screens/map_screen.dart ---
@'
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supa = Supabase.instance.client;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();
  LatLng? _me;
  StreamSubscription<Position>? _posSub;

  List<Map<String, dynamic>> _lights = [];
  List<Map<String, dynamic>> _marks = [];
  RealtimeChannel? _marksChannel;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadLights();
    _loadMarks();
    _subscribeMarks();
  }

  Future<void> _initLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _me = LatLng(pos.latitude, pos.longitude));
      _map.move(_me!, 16);
      _posSub = Geolocator.getPositionStream().listen((p) {
        setState(() => _me = LatLng(p.latitude, p.longitude));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
      }
    }
  }

  Future<void> _loadLights() async {
    final res = await supa.from('lights').select('id,name,lat,lon').order('id');
    setState(() => _lights = List<Map<String, dynamic>>.from(res));
  }

  Future<void> _loadMarks() async {
    final res = await supa.from('record_marks').select('id,lat,lon,note,ts,created_by').order('ts', ascending: false);
    setState(() => _marks = List<Map<String, dynamic>>.from(res));
  }

  void _subscribeMarks() {
    _marksChannel = supa
        .channel('public:record_marks')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'record_marks',
          callback: (payload) {
            final r = payload.newRecord;
            if (r == null) return;
            setState(() => _marks.insert(0, r));
          },
        )
        .subscribe();
  }

  Future<void> _addLight(LatLng p) async {
    final nameCtrl = TextFieldDialog.getController('light_${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}');
    final ok = await TextFieldDialog.ask(context, 'Add traffic light', nameCtrl);
    if (ok != true) return;
    final u = supa.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in required')));
      return;
    }
    await supa.from('lights').insert({'name': nameCtrl.text.trim(), 'lat': p.latitude, 'lon': p.longitude, 'created_by': u.id});
    await _loadLights();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    if (_marksChannel != null) supa.removeChannel(_marksChannel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _me ?? const LatLng(55.751244, 37.618423);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Lights'),
        actions: [
          IconButton(onPressed: _loadLights, icon: const Icon(Icons.traffic)),
          IconButton(onPressed: _loadMarks, icon: const Icon(Icons.flag)),
          IconButton(onPressed: () { if (_me != null) _map.move(_me!, 16); }, icon: const Icon(Icons.my_location)),
        ],
      ),
      body: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 14,
          onLongPress: (tapPos, latlng) => _addLight(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.green_wave_app',
          ),
          MarkerLayer(markers: _marks.map((m) {
            final p = LatLng((m['lat'] as num).toDouble(), (m['lon'] as num).toDouble());
            final note = (m['note'] ?? '').toString();
            final ts = (m['ts'] ?? '').toString();
            return Marker(point: p, width: 36, height: 36, child: Tooltip(message: note.isEmpty ? ts : '$note\n$ts', child: const Icon(Icons.flag, color: Colors.orange, size: 28)));
          }).toList()),
          MarkerLayer(markers: _lights.map((l) {
            final p = LatLng((l['lat'] as num).toDouble(), (l['lon'] as num).toDouble());
            return Marker(point: p, width: 44, height: 44, child: Tooltip(message: (l['name'] ?? 'light').toString(), child: const Icon(Icons.traffic, color: Colors.red, size: 32)));
          }).toList()),
          if (_me != null)
            MarkerLayer(markers: [
              Marker(point: _me!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue, size: 32)),
            ]),
        ],
      ),
    );
  }
}

class TextFieldDialog {
  static TextEditingController getController(String init) => TextEditingController(text: init);
  static Future<bool?> ask(BuildContext context, String title, TextEditingController c) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 .\lib\screens\map_screen.dart

# --- lib/screens/cycle_recorder.dart (with auto-detect + mark here) ---
@'
import "dart:async";
import "dart:math";
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:permission_handler/permission_handler.dart";
import "package:geolocator/geolocator.dart";

final supa = Supabase.instance.client;

class CycleRecorderScreen extends StatefulWidget {
  const CycleRecorderScreen({super.key});
  @override
  State<CycleRecorderScreen> createState() => _CycleRecorderScreenState();
}

class _CycleRecorderScreenState extends State<CycleRecorderScreen> {
  CameraController? _cam;
  List<CameraDescription> _cams = [];
  bool _camReady = false;
  bool _autoDetect = false;
  int _stableCount = 0;
  String? _lastAuto;

  List<Map<String, dynamic>> _lights = [];
  int? _selectedLightId;

  String? _curPhase;
  DateTime? _curStart;
  final List<Map<String, dynamic>> _segments = [];

  @override
  void initState() {
    super.initState();
    _loadLights();
    _initCamera();
  }

  Future<void> _loadLights() async {
    final res = await supa.from("lights").select("id,name").order("id");
    setState(() => _lights = List<Map<String, dynamic>>.from(res));
  }

  Future<void> _initCamera() async {
    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
      }
      return;
    }
    try {
      _cams = await availableCameras();
      final cam = _cams.first;
      _cam = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cam!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

  void _markPhase(String phase) {
    final now = DateTime.now();
    if (_curPhase != null && _curStart != null) {
      _segments.add({"phase": _curPhase, "start": _curStart, "end": now});
    }
    _curPhase = phase;
    _curStart = now;
    setState(() {});
  }

  Future<void> _stopAndUpload() async {
    if (_curPhase != null && _curStart != null) {
      _segments.add({"phase": _curPhase, "start": _curStart, "end": DateTime.now()});
      _curPhase = null;
      _curStart = null;
    }
    if (_segments.isEmpty || _selectedLightId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No segments or light not selected")));
      return;
    }
    final u = supa.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in required")));
      return;
    }
    final rows = _segments.map((s)=> {
      "light_id": _selectedLightId,
      "phase": s["phase"],
      "start_ts": (s["start"] as DateTime).toIso8601String(),
      "end_ts": (s["end"] as DateTime).toIso8601String(),
      "source": "camera",
      "created_by": u.id,
    }).toList();
    await supa.from("light_cycles").insert(rows);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded")));
    setState(() => _segments.clear());
  }

  Future<void> _markHere() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission denied")));
      }
      return;
    }
    final p = await Geolocator.getCurrentPosition();
    final u = supa.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in required")));
      return;
    }
    await supa.from("record_marks").insert({
      "lat": p.latitude, "lon": p.longitude, "note": "record mark", "created_by": u.id,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked on map")));
    }
  }

  void _toggleAuto() async {
    if (!_camReady || _cam == null) return;
    if (!_autoDetect) {
      try {
        await _cam!.startImageStream(_onImage);
        _autoDetect = true;
        _stableCount = 0;
        _lastAuto = null;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stream error: $e")));
      }
    } else {
      try { await _cam!.stopImageStream(); } catch (_) {}
      _autoDetect = false;
    }
    setState(() {});
  }

  int _w = 0, _h = 0;
  DateTime _lastDecision = DateTime.fromMillisecondsSinceEpoch(0);

  void _onImage(CameraImage img) {
    _w = img.width; _h = img.height;
    if (img.format.group != ImageFormatGroup.yuv420) return;

    final planeY = img.planes[0];
    final planeU = img.planes[1];
    final planeV = img.planes[2];

    final cx = _w ~/ 2;
    final cy = _h ~/ 3;
    int rC=0, gC=0, yC=0, total=0;

    for (int dy=-20; dy<=20; dy+=4) {
      final y0 = cy+dy;
      if (y0<0 || y0>=_h) continue;
      for (int dx=-20; dx<=20; dx+=4) {
        final x0 = cx+dx;
        if (x0<0 || x0>=_w) continue;

        final Y = planeY.bytes[y0*planeY.bytesPerRow + x0] & 0xFF;
        final uvx = (x0/2).floor();
        final uvy = (y0/2).floor();
        final uIndex = uvy*planeU.bytesPerRow + uvx*planeU.bytesPerPixel!;
        final vIndex = uvy*planeV.bytesPerRow + uvx*planeV.bytesPerPixel!;
        int U = planeU.bytes[uIndex] & 0xFF;
        int V = planeV.bytes[vIndex] & 0xFF;

        double C = Y - 16;
        double D = U - 128;
        double E = V - 128;
        double R = (1.164*C + 1.596*E);
        double G = (1.164*C - 0.392*D - 0.813*E);
        double B = (1.164*C + 2.017*D);

        R = R.clamp(0,255);
        G = G.clamp(0,255);
        B = B.clamp(0,255);

        if (R>150 && G<130) rC++;
        else if (G>150 && R<140) gC++;
        else if (R>150 && G>150) yC++;

        total++;
      }
    }

    String? guess;
    final th = max(8, (total*0.08).floor());
    if (rC>gC && rC>yC && rC>th) guess="red";
    else if (gC>rC && gC>yC && gC>th) guess="green";
    else if (yC>rC && yC>gC && yC>th) guess="yellow";

    if (guess!=null) {
      if (_lastAuto==guess) _stableCount++; else { _stableCount=1; _lastAuto=guess; }
      final now = DateTime.now();
      if (_stableCount>=6 && now.difference(_lastDecision).inMilliseconds>400) {
        _lastDecision = now;
        if (mounted) {
          _markPhase(guess);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Auto: $guess")));
        }
      }
    }
  }

  @override
  void dispose() {
    try { _cam?.stopImageStream(); } catch (_) {}
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _cam!=null && _camReady ? _cam!.value.aspectRatio : 16/9;
    return Scaffold(
      appBar: AppBar(title: const Text("Cycle Recorder")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: ratio,
            child: _cam!=null && _camReady ? CameraPreview(_cam!) : const ColoredBox(color: Colors.black12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<int>(
              value: _selectedLightId,
              items: _lights.map((l)=>DropdownMenuItem<int>(
                value: l["id"] as int,
                child: Text("${l["id"]}: ${l["name"] ?? "light"}"),
              )).toList(),
              onChanged: (v)=>setState(()=>_selectedLightId=v),
              decoration: const InputDecoration(labelText: "Traffic light"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(spacing: 8, children: [
              ElevatedButton(onPressed: ()=>_markPhase("red"), child: const Text("Red")),
              ElevatedButton(onPressed: ()=>_markPhase("yellow"), child: const Text("Yellow")),
              ElevatedButton(onPressed: ()=>_markPhase("green"), child: const Text("Green")),
              OutlinedButton(onPressed: _stopAndUpload, child: const Text("Stop & Upload")),
              OutlinedButton(onPressed: _markHere, child: const Text("Mark here")),
              ElevatedButton(onPressed: _toggleAuto, child: Text(_autoDetect ? "Auto Detect: ON" : "Auto Detect: OFF")),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _segments.length,
              itemBuilder: (c, i) {
                final s = _segments[i];
                return ListTile(
                  dense: true,
                  title: Text("${s["phase"]}"),
                  subtitle: Text("${s["start"]} -> ${s["end"]}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 .\lib\screens\cycle_recorder.dart

# --- lib/screens/speed_advisor.dart ---
@'
import "dart:math";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:supabase_flutter/supabase_flutter.dart";

final supa = Supabase.instance.client;

class SpeedAdvisorScreen extends StatefulWidget {
  const SpeedAdvisorScreen({super.key});
  @override
  State<SpeedAdvisorScreen> createState() => _SpeedAdvisorScreenState();
}

class _SpeedAdvisorScreenState extends State<SpeedAdvisorScreen> {
  List<Map<String, dynamic>> _lights = [];
  int? _lightId;
  Map<String, dynamic>? _lightRow;

  String _status = "Pick a light";
  double? _suggestMin;
  double? _suggestMax;

  @override
  void initState() {
    super.initState();
    _loadLights();
  }

  Future<void> _loadLights() async {
    final res = await supa.from("lights").select("id,name,lat,lon").order("id");
    setState(() => _lights = List<Map<String, dynamic>>.from(res));
  }

  Future<Position?> _pos() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2){
    const R = 6371000.0;
    final p = pi/180.0;
    final dlat = (lat2-lat1)*p, dlon = (lon2-lon1)*p;
    final a = sin(dlat/2)*sin(dlat/2) + cos(lat1*p)*cos(lat2*p)*sin(dlon/2)*sin(dlon/2);
    final c = 2*atan2(sqrt(a), sqrt(1-a));
    return R*c;
  }

  Future<void> _compute() async {
    if (_lightRow == null) return;

    setState(() { _status = "Computing..."; _suggestMin = null; _suggestMax = null; });

    final p = await _pos();
    if (p == null) { setState(() { _status = "Location denied"; }); return; }

    final dMeters = _haversine(
      p.latitude, p.longitude,
      (_lightRow!["lat"] as num).toDouble(),
      (_lightRow!["lon"] as num).toDouble()
    );

    double vNow = 0.0;
    try { final s = await Geolocator.getCurrentPosition(); vNow = s.speed; } catch (_) {}

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final twoHoursAgo = DateTime.now().toUtc().subtract(const Duration(hours: 2)).toIso8601String();
    final rows = await supa
      .from("light_cycles")
      .select("phase,start_ts,end_ts")
      .eq("light_id", _lightRow!["id"])
      .gte("start_ts", twoHoursAgo)
      .lte("end_ts", nowIso)
      .order("start_ts");

    final data = List<Map<String,dynamic>>.from(rows);
    if (data.isEmpty) { setState(() { _status = "No cycles in last 2h. Record some first."; }); return; }

    double sumRed=0, sumGreen=0, sumYellow=0; int nRed=0, nGreen=0, nYellow=0;
    DateTime? lastEnd;
    for (final r in data) {
      final s = DateTime.parse(r["start_ts"]).toUtc();
      final e = DateTime.parse(r["end_ts"]).toUtc();
      final dt = e.difference(s).inMilliseconds/1000.0;
      final ph = (r["phase"] as String).toLowerCase();
      if (ph=="red") { sumRed+=dt; nRed++; }
      if (ph=="green") { sumGreen+=dt; nGreen++; }
      if (ph=="yellow") { sumYellow+=dt; nYellow++; }
      lastEnd = e;
    }
    final red = nRed>0 ? sumRed/nRed : 30.0;
    final green = nGreen>0 ? sumGreen/nGreen : 30.0;
    final yellow = nYellow>0 ? sumYellow/nYellow : 4.0;
    final cycle = red + green + yellow;

    final tNow = DateTime.now().toUtc();
    final anchor = lastEnd ?? DateTime.now().toUtc();
    final dtFromAnchor = tNow.difference(anchor).inMilliseconds/1000.0;
    final tInCycle = (dtFromAnchor % cycle + cycle) % cycle;

    final greenStart = red;
    final greenEnd = red + green;

    double vMin = double.nan, vMax = double.nan;
    bool found = false;

    for (int k=0; k<5 && !found; k++){
      final windowStart = k*cycle + (greenStart - tInCycle);
      final windowEnd   = k*cycle + (greenEnd   - tInCycle);
      final ws = max(windowStart, 0);
      final we = max(windowEnd, 0.1);
      final vmaxCand = dMeters / ws;
      final vminCand = dMeters / we;
      final lower = min(vminCand, vmaxCand);
      final upper = max(vminCand, vmaxCand);
      if (lower.isFinite && upper.isFinite && upper > 0) {
        vMin = max(0.1, lower);
        vMax = upper;
        found = true;
      }
    }

    if (!found) { setState(() { _status = "No feasible window soon"; }); return; }

    final clampMin = 5.0;   // ~18 km/h
    final clampMax = 25.0;  // ~90 km/h
    final sMin = max(clampMin, vMin);
    final sMax = min(clampMax, vMax);

    String txt = "Distance: ${dMeters.toStringAsFixed(0)} m; cycle ~ ${cycle.toStringAsFixed(0)} s, green ~ ${green.toStringAsFixed(0)} s. ";
    if (sMin > sMax) { setState(() { _status = txt + "No safe speed window in limits."; }); return; }

    _suggestMin = sMin * 3.6; _suggestMax = sMax * 3.6;
    String verdict;
    if (vNow>0 && vNow*3.6 >= _suggestMin! && vNow*3.6 <= _suggestMax!) verdict = "Keep speed";
    else if (vNow*3.6 < _suggestMin!) verdict = "Speed up";
    else verdict = "Slow down";

    setState(() {
      _status = txt + "Recommended: ${_suggestMin!.toStringAsFixed(0)}..${_suggestMax!.toStringAsFixed(0)} km/h ($verdict)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speed Advisor")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _lightId,
              items: _lights.map((l) => DropdownMenuItem<int>(
                value: l["id"] as int,
                child: Text("${l["id"]}: ${l["name"] ?? "light"}"),
              )).toList(),
              onChanged: (v) { setState(() { _lightId = v; _lightRow = _lights.firstWhere((e)=>e["id"]==v); }); },
              decoration: const InputDecoration(labelText: "Traffic light"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _compute, child: const Text("Compute advice")),
            const SizedBox(height: 12),
            Text(_status),
            if (_suggestMin!=null && _suggestMax!=null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text("Go ~ ${_suggestMin!.toStringAsFixed(0)}..${_suggestMax!.toStringAsFixed(0)} km/h",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 .\lib\screens\speed_advisor.dart

# --- SQL files ---

@'
-- public.todos
create table if not exists public.todos (
  id bigint generated by default as identity primary key,
  task text not null,
  status text default 'Not Started',
  user_id uuid not null references auth.users(id) on delete cascade,
  inserted_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.todos enable row level security;
create policy "todos read own"   on public.todos for select using (auth.uid() = user_id);
create policy "todos insert own" on public.todos for insert with check (auth.uid() = user_id);
create policy "todos update own" on public.todos for update using (auth.uid() = user_id);
create policy "todos delete own" on public.todos for delete using (auth.uid() = user_id);
'@ | Set-Content -Encoding UTF8 .\supabase_1_todos.sql

@'
-- public.lights
create table if not exists public.lights (
  id bigserial primary key,
  name text,
  lat double precision not null,
  lon double precision not null,
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);
alter table public.lights enable row level security;
create policy "lights read all"   on public.lights for select using (true);
create policy "lights insert own" on public.lights for insert with check (auth.uid() = created_by);
create policy "lights update own" on public.lights for update using (auth.uid() = created_by);
'@ | Set-Content -Encoding UTF8 .\supabase_2_lights.sql

@'
-- public.light_cycles
create table if not exists public.light_cycles (
  id bigserial primary key,
  light_id bigint references public.lights(id) on delete cascade,
  phase text check (phase in ('red','green','yellow')) not null,
  start_ts timestamptz not null,
  end_ts   timestamptz not null,
  source text default 'camera',
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);
alter table public.light_cycles enable row level security;
create policy "cycles read all"   on public.light_cycles for select using (true);
create policy "cycles insert own" on public.light_cycles for insert with check (auth.uid() = created_by);
create policy "cycles update own" on public.light_cycles for update using (auth.uid() = created_by);
'@ | Set-Content -Encoding UTF8 .\supabase_3_light_cycles.sql

@'
-- public.record_marks
create table if not exists public.record_marks (
  id bigserial primary key,
  lat double precision not null,
  lon double precision not null,
  note text,
  ts timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete cascade
);
alter table public.record_marks enable row level security;
create policy "marks read all"   on public.record_marks for select using (true);
create policy "marks insert own" on public.record_marks for insert with check (auth.uid() = created_by);
create policy "marks update own" on public.record_marks for update using (auth.uid() = created_by);
'@ | Set-Content -Encoding UTF8 .\supabase_4_record_marks.sql

# --- fetch deps ---
flutter pub get

Write-Host ""
Write-Host "=== DONE ==="
Write-Host "Next steps:"
Write-Host "1) Supabase -> SQL Editor: run in order:"
Write-Host "   - ./supabase_1_todos.sql"
Write-Host "   - ./supabase_2_lights.sql"
Write-Host "   - ./supabase_3_light_cycles.sql"
Write-Host "   - ./supabase_4_record_marks.sql"
Write-Host "2) flutter run   (login, map, record, advisor)"
Write-Host "3) flutter build apk --release (APK -> build\\app\\outputs\\flutter-apk\\app-release.apk)"
