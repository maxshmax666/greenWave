import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'env.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'theme_colors.dart';

import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';

import 'theme_colors.dart';
import 'app_colors.dart';

import 'features/auth/presentation/register_page.dart';
import 'shared/constants/app_colors.dart';
import 'shared/constants/app_strings.dart';
import 'shared/theme/app_theme.dart';



const supabaseUrl = 'https://asoyjqtqtomxcdmsgehx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzb3lqcXRxdG9teGNkbXNnZWh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDc2NzIsImV4cCI6MjA3MDY4MzY3Mn0.AgVnUEmf4dO3aaVBJjZ1zJm0EFUQ0ghENtpkRqsXW4o';

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
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              themeMode: mode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ru'), Locale('en')],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: color),
                useMaterial3: true,
                focusColor: color.shade200,
                focusIndicatorTheme:
                    const FocusIndicatorThemeData(outlineColor: Colors.orange),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: color,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                focusColor: color.shade200,
                focusIndicatorTheme:
                    const FocusIndicatorThemeData(outlineColor: Colors.orange),
              ),
              debugShowCheckedModeBanner: false,
              home: const AuthGate(),
            ),

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
      final l = AppLocalizations.of(context)!;
      return Scaffold(
        drawer: Drawer(
          backgroundColor: AppColors.leftPanelBg,
          child: SafeArea(
            child: ListTile(
              title: Text(
                l.slogan,
                style:
                    const TextStyle(color: AppColors.leftPanelText),
              ),
            ),
          ),
        ),
        body: pages[_i],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _i,
          onTap: (v) => setState(() => _i = v),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map, semanticLabel: l.map),
              label: l.map,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.traffic, semanticLabel: l.lights),
              label: l.lights,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, semanticLabel: l.settings),
              label: l.settings,
            ),
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
      final l = AppLocalizations.of(context)!;
      return Scaffold(
        appBar:
            AppBar(title: Text(isLogin ? l.signIn : l.signUp)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: l.email,
                hintText: l.emailHint,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passCtrl,
              decoration: InputDecoration(
                labelText: l.password,
                hintText: l.passwordHint,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: isLogin ? l.signIn : l.createAccount,
              child: ElevatedButton(
                onPressed: busy ? null : _submit,
                child: Text(isLogin ? l.signIn : l.createAccount),
              ),
            ),
            Semantics(
              button: true,
              label: isLogin ? l.createAccount : l.haveAccount,
              child: TextButton
                onPressed: () => setState(() => isLogin = !isLogin),
                child:
                    Text(isLogin ? l.createAccount : l.haveAccount),
              ),
            ),
          ]),
        ),
      );
  }
}


