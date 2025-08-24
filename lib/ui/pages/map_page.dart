import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/location_service.dart';
import '../../domain/models/light.dart';
import '../../domain/models/light_cycle.dart';
import '../../shared/settings.dart';
import '../widgets/next_light_card.dart';
import '../widgets/route_bottom_panel.dart';
import '../widgets/turn_card.dart';

/// Map page displaying navigation widgets and controls.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _controller = MapController();
  LatLng _center = const LatLng(0, 0);
  Light? _nextLight;
  LightCycle? _cycle;

  @override
  void initState() {
    super.initState();
    _centerOnUser();
    _loadMockLight();
  }

  void _loadMockLight() {
    final now = DateTime.now();
    _nextLight = Light(id: 1, name: 'ул. Ленина', lat: 0, lon: 0);
    _cycle = LightCycle(
      lightId: 1,
      phase: 'green',
      startTs: now,
      endTs: now.add(const Duration(seconds: 30)),
    );
  }

  Future<void> _centerOnUser() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = latLng);
      _controller.move(latLng, 16);
    }
  }

  double? _recommendedSpeed() {
    if (_cycle == null) return null;
    const distM = 200.0;
    final tLeft = _cycle!.endTs.difference(DateTime.now()).inSeconds;
    if (_cycle!.phase == 'green' && tLeft > 0) {
      final v = (distM / tLeft) * 3.6;
      return v.clamp(Settings.vMin, Settings.vMax);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lightCard = (_nextLight != null && _cycle != null && Settings.showLightCard)
        ? NextLightCard(
            light: _nextLight!,
            cycle: _cycle!,
            recommendedSpeed: _recommendedSpeed(),
          )
        : null;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: const [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.green_wave_app',
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: const TurnCard(),
              ),
            ),
          ),
          if (lightCard != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: lightCard,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: const RouteBottomPanel(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
