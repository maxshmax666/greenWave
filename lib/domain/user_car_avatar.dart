import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserCarAvatar {
  static const _enabledKey = 'car_avatar_enabled';
  static const _sizeKey = 'car_avatar_size';
  static const _rotateKey = 'car_avatar_rotate';
  static const _defaultSize = 56.0;
  static const _fileName = 'me.png';

  static Future<File> _destFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final avatars = Directory('${dir.path}/avatars');
    if (!await avatars.exists()) {
      await avatars.create(recursive: true);
    }
    return File('${avatars.path}/$_fileName');
  }

  static Future<File?> getFile() async {
    final f = await _destFile();
    return await f.exists() ? f : null;
  }

  static Future<void> setFromLocalPath(String srcPath) async {
    final src = File(srcPath);
    if (!await src.exists()) return;
    final dst = await _destFile();
    await src.copy(dst.path);
    await setEnabled(true);
  }

  static Future<void> setFromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return;
      final dst = await _destFile();
      await dst.writeAsBytes(res.bodyBytes);
      await setEnabled(true);
    } catch (_) {}
  }

  static Future<void> clear() async {
    final f = await getFile();
    if (f != null && await f.exists()) {
      await f.delete();
    }
    await setEnabled(false);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, v);
  }

  static Future<double> getSizePx() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sizeKey) ?? _defaultSize;
  }

  static Future<void> setSizePx(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sizeKey, v);
  }

  static Future<bool> getRotateByHeading() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rotateKey) ?? false;
  }

  static Future<void> setRotateByHeading(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rotateKey, v);
  }

  static Future<Uint8List> readBytes() async {
    final f = await getFile();
    if (f == null) return Uint8List(0);
    return f.readAsBytes();
  }
}
