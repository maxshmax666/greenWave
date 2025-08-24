import 'package:flutter/material.dart';
import 'package:green_wave_app/l10n/generated/app_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supa = Supabase.instance.client;

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
      setState(
        () => _items
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(res)),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedLoadLights(e.toString()))),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lightsTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (c, i) {
            final l = _items[i];
            final lat = (l['lat'] as num?)?.toDouble();
            final lon = (l['lon'] as num?)?.toDouble();
            final subtitle = (lat != null && lon != null)
                ? '$lat, $lon'
                : l10n.noCoords;
            return ListTile(
              title: Text(
                l['name'] as String?
                    ?? l10n.lightWithId((l['id'] as num).toInt()),
              ),
              subtitle: Text(subtitle),
            );
          },
        ),
      ),
    );
  }
}
