import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';
import 'theme_colors.dart';

const supabaseUrl = 'https://asoyjqtqtomxcdmsgehx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzb3lqcXRxdG9teGNkbXNnZWh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDc2NzIsImV4cCI6MjA3MDY4MzY3Mn0.AgVnUEmf4dO3aaVBJjZ1zJm0EFUQ0ghENtpkRqsXW4o';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final themeColor = ValueNotifier<MaterialColor>(themeColors.first);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt('primary_color') ?? 0;
  if (colorIndex >= 0 && colorIndex < themeColors.length) {
    themeColor.value = themeColors[colorIndex];
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
        ? const LoginPage()
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool busy = false;

  Future<void> _submit() async {
    setState(() => busy = true);
    try {
      if (isLogin) {
        await supa.auth.signInWithPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await supa.auth.signUp(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget leftPane = Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Text(
          'GreenWave',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );

    Widget rightPane(double maxWidth) => ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: maxWidth < 900 ? double.infinity : 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? 'Sign in' : 'Sign up',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: busy ? null : _submit,
                  child: Text(isLogin ? 'Sign in' : 'Create account'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                      isLogin ? 'Create account' : 'I have an account'),
                ),
              ],
            ),
          ),
        );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final form = rightPane(w);
          if (w >= 1200) {
            return Row(
              children: [
                Expanded(flex: 6, child: leftPane),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(child: form),
                  ),
                ),
              ],
            );
          } else if (w >= 900) {
            return Row(
              children: [
                Expanded(flex: 5, child: leftPane),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(child: form),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                SizedBox(height: 280, width: double.infinity, child: leftPane),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(child: form),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
