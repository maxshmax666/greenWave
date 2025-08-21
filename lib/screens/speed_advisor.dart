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
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final p = pi / 180.0;
    final dlat = (lat2 - lat1) * p, dlon = (lon2 - lon1) * p;
    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1 * p) * cos(lat2 * p) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _compute() async {
    if (_lightRow == null) return;

    setState(() {
      _status = "Computing...";
      _suggestMin = null;
      _suggestMax = null;
    });

    final p = await _pos();
    if (p == null) {
      setState(() {
        _status = "Location denied";
      });
      return;
    }

    final dMeters = _haversine(
        p.latitude,
        p.longitude,
        (_lightRow!["lat"] as num).toDouble(),
        (_lightRow!["lon"] as num).toDouble());

    double vNow = 0.0;
    try {
      final s = await Geolocator.getCurrentPosition();
      vNow = s.speed;
    } catch (_) {}

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final twoHoursAgo = DateTime.now()
        .toUtc()
        .subtract(const Duration(hours: 2))
        .toIso8601String();
    final rows = await supa
        .from("light_cycles")
        .select("phase,start_ts,end_ts")
        .eq("light_id", _lightRow!["id"])
        .gte("start_ts", twoHoursAgo)
        .lte("end_ts", nowIso)
        .order("start_ts");

    final data = List<Map<String, dynamic>>.from(rows);
    if (data.isEmpty) {
      setState(() {
        _status = "No cycles in last 2h. Record some first.";
      });
      return;
    }

    double sumRed = 0, sumGreen = 0, sumYellow = 0;
    int nRed = 0, nGreen = 0, nYellow = 0;
    DateTime? lastEnd;
    for (final r in data) {
      final s = DateTime.parse(r["start_ts"]).toUtc();
      final e = DateTime.parse(r["end_ts"]).toUtc();
      final dt = e.difference(s).inMilliseconds / 1000.0;
      final ph = (r["phase"] as String).toLowerCase();
      if (ph == "red") {
        sumRed += dt;
        nRed++;
      }
      if (ph == "green") {
        sumGreen += dt;
        nGreen++;
      }
      if (ph == "yellow") {
        sumYellow += dt;
        nYellow++;
      }
      lastEnd = e;
    }
    final red = nRed > 0 ? sumRed / nRed : 30.0;
    final green = nGreen > 0 ? sumGreen / nGreen : 30.0;
    final yellow = nYellow > 0 ? sumYellow / nYellow : 4.0;
    final cycle = red + green + yellow;

    final tNow = DateTime.now().toUtc();
    final anchor = lastEnd ?? DateTime.now().toUtc();
    final dtFromAnchor = tNow.difference(anchor).inMilliseconds / 1000.0;
    final tInCycle = (dtFromAnchor % cycle + cycle) % cycle;

    final greenStart = red;
    final greenEnd = red + green;

    double vMin = double.nan, vMax = double.nan;
    bool found = false;

    for (int k = 0; k < 5 && !found; k++) {
      final windowStart = k * cycle + (greenStart - tInCycle);
      final windowEnd = k * cycle + (greenEnd - tInCycle);
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

    if (!found) {
      setState(() {
        _status = "No feasible window soon";
      });
      return;
    }

    final clampMin = 5.0; // ~18 km/h
    final clampMax = 25.0; // ~90 km/h
    final sMin = max(clampMin, vMin);
    final sMax = min(clampMax, vMax);

    String txt =
        "Distance: ${dMeters.toStringAsFixed(0)} m; cycle ~ ${cycle.toStringAsFixed(0)} s, green ~ ${green.toStringAsFixed(0)} s. ";
    if (sMin > sMax) {
      setState(() {
        _status = txt + "No safe speed window in limits.";
      });
      return;
    }

    _suggestMin = sMin * 3.6;
    _suggestMax = sMax * 3.6;
    String verdict;
    if (vNow > 0 && vNow * 3.6 >= _suggestMin! && vNow * 3.6 <= _suggestMax!)
      verdict = "Keep speed";
    else if (vNow * 3.6 < _suggestMin!)
      verdict = "Speed up";
    else
      verdict = "Slow down";

    setState(() {
      _status = txt +
          "Recommended: ${_suggestMin!.toStringAsFixed(0)}..${_suggestMax!.toStringAsFixed(0)} km/h ($verdict)";
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
              items: _lights
                  .map((l) => DropdownMenuItem<int>(
                        value: l["id"] as int,
                        child: Text("${l["id"]}: ${l["name"] ?? "light"}"),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _lightId = v;
                  _lightRow = _lights.firstWhere((e) => e["id"] == v);
                });
              },
              decoration: const InputDecoration(labelText: "Traffic light"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: _compute, child: const Text("Compute advice")),
            const SizedBox(height: 12),
            Text(_status),
            if (_suggestMin != null && _suggestMax != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                    "Go ~ ${_suggestMin!.toStringAsFixed(0)}..${_suggestMax!.toStringAsFixed(0)} km/h",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
