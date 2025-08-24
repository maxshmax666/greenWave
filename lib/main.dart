import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';
import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';
import 'shared/constants/app_colors.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final themeColor = ValueNotifier<MaterialColor>(AppColors.themeColors.first);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt('primary_color') ?? 0;
  if (colorIndex >= 0 && colorIndex < AppColors.themeColors.length) {
    themeColor.value = AppColors.themeColors[colorIndex];
  }

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  final savedSession = prefs.getString(Env.supabaseSessionKey);
  if (savedSession != null) {
    try {
      await Supabase.instance.client.auth.recoverSession(savedSession);
    } catch (_) {}
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session != null) {
      await prefs.setString(
        Env.supabaseSessionKey,
        session.persistSessionString,
      );
    } else {
      await prefs.remove(Env.supabaseSessionKey);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MaterialColor>(
      valueListenable: themeColor,
      builder: (context, color, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: mode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: color),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: color,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              // locale: const Locale('ru'),
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
    final pages = const [MapScreen(), LightsScreen(), SettingsScreen()];
    final items = [
      BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.navMap),
      BottomNavigationBarItem(
        icon: const Icon(Icons.traffic),
        label: l10n.navLights,
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
