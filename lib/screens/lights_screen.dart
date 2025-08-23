import 'package:flutter/material.dart';
import '../main.dart';

/// Simple list of traffic lights loaded from Supabase.
class LightsScreen extends StatefulWidget {
  const LightsScreen({super.key});

  @override
  State<LightsScreen> createState() => _LightsScreenState();
}

class _LightsScreenState extends State<LightsScreen> {
  final List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    try {
      final res = await supa
          .from('lights')
          .select('id,name,lat,lon')
          .order('id');
      setState(() => _items
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(res)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load lights: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Светофоры')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (c, i) {
            final l = _items[i];
            final lat = (l['lat'] as num?)?.toDouble();
            final lon = (l['lon'] as num?)?.toDouble();
            final subtitle =
                (lat != null && lon != null) ? '$lat, $lon' : 'no coords';
            return ListTile(
              title: Text(l['name'] as String? ?? 'Light ${l['id']}'),
              subtitle: Text(subtitle),
            );
          },
        ),
      ),
    );
  }
}
