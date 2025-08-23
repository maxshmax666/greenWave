
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'shared/analytics/analytics.dart';
=======

import 'env.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'theme_colors.dart';


import 'screens/map_screen.dart';
import 'screens/lights_screen.dart';
import 'screens/settings_screen.dart';

import 'theme_colors.dart';

import 'app_theme.dart';
import 'glowing_button.dart';

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
            title: 'GreenWave',


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
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool busy = false;
  bool acceptTerms = false;
  bool obscure = true;
  bool isValid = false;
  String passStrength = '';

  void _updateValid() {
    setState(() => isValid = formKey.currentState?.validate() ?? false);
  }

  String _calcStrength(String v) {
    if (v.isEmpty) return '';
    int score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(v)) score++;
    if (RegExp(r'\d').hasMatch(v)) score++;
    if (score <= 1) return 'Слабый';
    if (score == 2) return 'Средний';
    return 'Сильный';
  }

  Color _strengthColor() {
    switch (passStrength) {
      case 'Слабый':
        return Colors.red;
      case 'Средний':
        return Colors.orange;
      case 'Сильный':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    analytics.logEvent('slogan_shown');

  String _translateError(dynamic error) {
    const translations = {
      'Invalid login credentials': 'Неверный email или пароль',
      'Email not confirmed': 'Email не подтвержден',
      'User already registered': 'Пользователь уже зарегистрирован',
      'Network request failed': 'Ошибка сети. Проверьте соединение.',
    };
    if (error is AuthException) {
      return translations[error.message] ?? error.message;
    }
    if (error is SocketException) {
      return translations['Network request failed']!;
    }
    return error.toString();

  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate() || !acceptTerms) return;
    setState(() => busy = true);
    try {
      if (isLogin) {
        await supa.auth.signInWithPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
        await analytics.logEvent('login_success');
      } else {
        await supa.auth.signUp(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
        await analytics.logEvent('signup_success');
      }

    } catch (e) {
      await analytics.logEvent(
        isLogin ? 'login_failure' : 'signup_failure',
        {'error': e.toString()},
      );

    } catch (e, st) {
      debugPrint('Auth error: $e\n$st');

      if (!mounted) return;
      final msg = _translateError(e);
      final isNetwork =
          e is SocketException || (e is AuthException && e.message == 'Network request failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: isNetwork
              ? SnackBarAction(label: 'Повторить', onPressed: _submit)
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final disableAnimations = MediaQuery.of(context).disableAnimations;



    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
 
        child: Form(
          key: formKey,
          child: Column(children: [
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите email';
                const pattern =
                    r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
                if (!RegExp(pattern).hasMatch(v.trim())) {
                  return 'Неверный email';
                }
                return null;
              },
              onChanged: (_) => _updateValid(),
            ),
            TextFormField(
              controller: passCtrl,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
              obscureText: obscure,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите пароль';
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}')
                    .hasMatch(v)) {
                  return 'Пароль \u22658 символов, минимум одна буква и цифра';
                }
                return null;
              },
              onChanged: (v) {
                passStrength = _calcStrength(v);
                _updateValid();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                passStrength.isEmpty ? '' : 'Пароль: $passStrength',
                style: TextStyle(color: _strengthColor()),
              ),
            ),
            CheckboxListTile(
              value: acceptTerms,
              onChanged: (v) => setState(() => acceptTerms = v ?? false),
              title: const Text('Принимаю условия'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  (!busy && isValid && acceptTerms) ? _submit : null,
              child: Text(isLogin ? 'Sign in' : 'Create account'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child:
                  Text(isLogin ? 'Create account' : 'I have an account'),
            ),
          ]),
        ),

        child: Column(children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            enabled: !busy,
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            enabled: !busy,
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: busy ? null : _submit,

            style:
                disableAnimations ? ElevatedButton.styleFrom(elevation: 0) : null,
            child: Text(isLogin ? 'Sign in' : 'Create account'),

            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLogin ? 'Sign in' : 'Create account'),

          ),
          TextButton(
            onPressed: busy ? null : () => setState(() => isLogin = !isLogin),
            child: Text(isLogin ? 'Create account' : 'I have an account'),

          GlowingButton(
            onPressed: _submit,
            text: isLogin ? 'Sign in' : 'Create account',
            loading: busy,
          ),
          const SizedBox(height: 8),
          GlowingButton(
            onPressed: () => setState(() => isLogin = !isLogin),
            text: isLogin ? 'Create account' : 'I have an account',
            tone: GlowingButtonTone.ghost,

          ),
        ]),

      ),
    );

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


