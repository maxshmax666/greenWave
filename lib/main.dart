import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'theme_colors.dart';

/// Global theme mode used across the app.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Primary color notifier.
final themeColor = ValueNotifier<MaterialColor>(themeColors.first);

/// Shortcut to the Supabase client.
final supa = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt('primary_color') ?? 0;
  if (colorIndex >= 0 && colorIndex < themeColors.length) {
    themeColor.value = themeColors[colorIndex];
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final savedSession = prefs.getString(Env.supabaseSessionKey);
  if (savedSession != null) {
    try {
      await Supabase.instance.client.auth.recoverSession(savedSession);
    } catch (_) {
      // ignore errors on session recovery
    }
  }

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
          builder: (context, mode, __) => MaterialApp(
            title: 'GreenWave',
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

