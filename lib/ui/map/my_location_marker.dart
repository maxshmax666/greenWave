import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/user_car_avatar.dart';

class MyLocationMarker extends StatelessWidget {
  final LatLng latLng;
  final double headingDeg;
  const MyLocationMarker({super.key, required this.latLng, required this.headingDeg});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AvatarData?>(
      future: _load(),
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) {
          return MarkerLayer(markers: [
            Marker(
              point: latLng,
              width: 16,
              height: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ]);
        }
        Widget img = ClipRRect(
          borderRadius: BorderRadius.circular(data.size * 0.12),
          child: Image.memory(
            data.bytes,
            width: data.size,
            height: data.size,
            fit: BoxFit.contain,
          ),
        );
        img = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.black38,
                blurRadius: data.size * 0.3,
                spreadRadius: data.size * 0.05,
              ),
            ],
          ),
          child: img,
        );
        if (data.rotate && headingDeg.isFinite) {
          img = Transform.rotate(angle: headingDeg * pi / 180, child: img);
        }
        return MarkerLayer(markers: [
          Marker(point: latLng, width: data.size, height: data.size, child: img),
        ]);
      },
    );
  }

  Future<_AvatarData?> _load() async {
    final enabled = await UserCarAvatar.isEnabled();
    if (!enabled) return null;
    final file = await UserCarAvatar.getFile();
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    final size = await UserCarAvatar.getSizePx();
    final rotate = await UserCarAvatar.getRotateByHeading();
    return _AvatarData(bytes, size, rotate);
  }
}

class _AvatarData {
  final Uint8List bytes;
  final double size;
  final bool rotate;
  _AvatarData(this.bytes, this.size, this.rotate);
}
