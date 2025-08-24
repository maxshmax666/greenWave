import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class to handle location permissions and fetching the current
/// position. Uses [permission_handler] to request runtime permissions and
/// [Geolocator] for obtaining the location.
class LocationService {
  /// Requests location permission. Returns `true` when granted.
  static Future<bool> ensurePermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Returns the current position when permission is granted, otherwise `null`.
  static Future<Position?> getCurrentPosition() async {
    final granted = await ensurePermission();
    if (!granted) return null;
    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }
}
