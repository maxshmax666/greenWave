import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';
import 'shared/constants/app_colors.dart';
import 'shared/constants/app_strings.dart';
import 'shared/theme/app_theme.dart';

const supabaseUrl = AppStrings.supabaseUrl;
const supabaseAnonKey = AppStrings.supabaseAnonKey;

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
final themeColor = ValueNotifier<MaterialColor>(AppColors.themeColors.first);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt('primary_color') ?? 0;
  if (colorIndex >= 0 && colorIndex < AppColors.themeColors.length) {
    themeColor.value = AppColors.themeColors[colorIndex];
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
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            themeMode: mode,
            theme: AppTheme.light(color),
            darkTheme: AppTheme.dark(color),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
            ],
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
    final pages = const [
      MapScreen(),
      LightsScreen(),
      SettingsScreen(),
    ];
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurfaceVariant,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.navMap),
          BottomNavigationBarItem(
              icon: const Icon(Icons.traffic), label: l10n.navLights),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings), label: l10n.navSettings),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          title: Text(isLogin ? l10n.signIn : l10n.signUp)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: passCtrl,
            decoration: InputDecoration(labelText: l10n.passwordLabel),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: busy ? null : _submit,
            child: Text(isLogin ? l10n.signIn : l10n.createAccount),
          ),
          TextButton(
            onPressed: () => setState(() => isLogin = !isLogin),
            child: Text(
                isLogin ? l10n.createAccount : l10n.iHaveAccount),
          ),
        ]),
      ),
    );
  }
}
