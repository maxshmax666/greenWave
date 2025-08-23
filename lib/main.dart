import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'env.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'theme_colors.dart';

import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';
import 'features/auth/presentation/register_page.dart';
import 'shared/constants/app_colors.dart';
import 'shared/constants/app_strings.dart';
import 'shared/theme/app_theme.dart';


final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final themeColor = ValueNotifier<MaterialColor>(AppColors.themeColors.first);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt('primary_color') ?? 0;
  if (colorIndex >= 0 && colorIndex < AppColors.themeColors.length) {
    themeColor.value = AppColors.themeColors[colorIndex];
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final storedSession = prefs.getString('supabase_session');
  if (storedSession != null) {
    await Supabase.instance.client.auth.recoverSession(storedSession);
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
    final session = event.session;
    if (session != null) {
      await prefs.setString(
          'supabase_session', session.persistSessionString);
    } else {
      await prefs.remove('supabase_session');
    }
  });

  runApp(const MyApp());
}

final supa = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MaterialColor>(
      valueListenable: themeColor,
      builder: (context, color, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, __) => MaterialApp(
            title: AppStrings.appTitle,
            themeMode: mode,
            theme: AppTheme.light(color),
            darkTheme: AppTheme.dark(color),
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
          ),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    supa.auth.onAuthStateChange.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return supa.auth.currentSession == null
        ? const RegisterPage()
        : const HomePage();
  }
}
=======
        : const HomeTabs();
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const MapScreen(),
      const LightsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Карта'),
          BottomNavigationBarItem(icon: Icon(Icons.traffic), label: 'Светофоры'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

