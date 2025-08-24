import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../domain/user_car_avatar.dart';

class CarAvatarTile extends StatefulWidget {
  const CarAvatarTile({super.key});

  @override
  State<CarAvatarTile> createState() => _CarAvatarTileState();
}

class _CarAvatarTileState extends State<CarAvatarTile> {
  Uint8List? _bytes;
  bool _enabled = false;
  double _size = 56;
  bool _rotate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await UserCarAvatar.isEnabled();
    final size = await UserCarAvatar.getSizePx();
    final rotate = await UserCarAvatar.getRotateByHeading();
    final bytes = await UserCarAvatar.readBytes();
    setState(() {
      _enabled = enabled;
      _size = size;
      _rotate = rotate;
      _bytes = bytes.isNotEmpty ? bytes : null;
    });
  }

  Future<void> _pickLocal() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = res?.files.single.path;
    if (path != null) {
      await UserCarAvatar.setFromLocalPath(path);
      await _load();
    }
  }

  Future<void> _fromUrl() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('OK')),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      await UserCarAvatar.setFromUrl(url);
      await _load();
    }
  }

  Future<void> _clear() async {
    await UserCarAvatar.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Мой автомобиль как маркер', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _bytes != null
            ? Image.memory(_bytes!, width: _size, height: _size, fit: BoxFit.contain)
            : const SizedBox(width: 56, height: 56, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(onPressed: _pickLocal, child: const Text('Выбрать из файлов')),
            ElevatedButton(onPressed: _fromUrl, child: const Text('Из URL')),
            TextButton(onPressed: _clear, child: const Text('Сбросить')),
          ],
        ),
        SwitchListTile(
          title: const Text('Использовать аватар'),
          value: _enabled,
          onChanged: (v) async {
            await UserCarAvatar.setEnabled(v);
            setState(() => _enabled = v);
          },
        ),
        ListTile(
          title: const Text('Размер иконки'),
          subtitle: Slider(
            value: _size,
            min: 32,
            max: 128,
            onChanged: (v) async {
              setState(() => _size = v);
              await UserCarAvatar.setSizePx(v);
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Поворачивать по курсу'),
          value: _rotate,
          onChanged: (v) async {
            await UserCarAvatar.setRotateByHeading(v);
            setState(() => _rotate = v);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
