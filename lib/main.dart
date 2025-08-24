// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_wave_app/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'env.dart';
import 'shared/constants/app_colors.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/register_page.dart';
import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/cycles_screen.dart';
import 'screens/cycle_recorder.dart';
import 'screens/settings_screen.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final themeColor = ValueNotifier<MaterialColor>(AppColors.themeColors.first);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  final status = await Permission.location.request();
  if (status.isGranted) {
    // Location permission granted; location services can be used.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<MaterialColor>(
          valueListenable: themeColor,
          builder: (context, color, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: mode,
              theme: AppTheme.light(color),
              darkTheme: AppTheme.dark(color),
              routes: {'/register': (_) => const RegisterPage()},
              home: const HomeTabs(),
            );
          },
        );
      },
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = const [
      MapScreen(),
      LightsScreen(),
      CyclesScreen(),
      CycleRecorderScreen(),
      SettingsScreen(),
    ];
    final items = [
      BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.navMap),
      BottomNavigationBarItem(
        icon: const Icon(Icons.traffic),
        label: l10n.navLights,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.timelapse),
        label: l10n.navCycles,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.place),
        label: l10n.navRecord,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: l10n.navSettings,
      ),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: items,
      ),
    );
  }
}
