import 'package:flutter/material.dart';
 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../env.dart';
import '../home/home_page.dart';

/// Simple authentication page allowing users to sign up, sign in and sign out
/// using Supabase authentication.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  /// Signs out the current user and clears the persisted session.
  static Future<void> signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Env.supabaseSessionKey);
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegisterPage()),
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }


import 'package:supabase_flutter/supabase_flutter.dart';

import '../../env.dart';

final supa = Supabase.instance.client;

/// Simple register/login page backed by Supabase auth.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

 
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
 
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;

  final _supa = Supabase.instance.client;

  Future<void> signUp() async {
    setState(() => _busy = true);
    try {
      final res = await _supa.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await _persistSession(res.session);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> signIn() async {
    setState(() => _busy = true);
    try {
      final res = await _supa.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await _persistSession(res.session);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _persistSession(Session? session) async {
    if (session == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      Env.supabaseSessionKey,
      session.persistSessionString,
    );

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool busy = false;

  Future<void> _signIn() async {
    setState(() => busy = true);
    try {
      await supa.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => busy = true);
    try {
      final res = await supa.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      if (res.session == null) {
        // Email confirmation required
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Проверьте почту для подтверждения')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _signOut() async {
    await supa.auth.signOut();
  }

  Future<void> _oauthLogin(Provider provider) async {
    try {
      await supa.auth.signInWithOAuth(provider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
 
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),

    final googleEnabled = Env.googleClientId.isNotEmpty;
    final appleEnabled = Env.appleClientId.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Sign up')),
 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
 
              controller: _emailCtrl,

              controller: emailCtrl,
 
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
 
              controller: _passCtrl,

              controller: passCtrl,
 
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
 
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : signIn,
                    child: const Text('Sign in'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : signUp,
                    child: const Text('Sign up'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : () => RegisterPage.signOut(context),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}


            ElevatedButton(
              onPressed: busy
                  ? null
                  : () => isLogin ? _signIn() : _signUp(),
              child: Text(isLogin ? 'Sign in' : 'Create account'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Create account' : 'I have an account'),
            ),
            const SizedBox(height: 32),
            if (googleEnabled)
              ElevatedButton(
                onPressed: () => _oauthLogin(Provider.google),
                child: const Text('Sign in with Google'),
              ),
            const SizedBox(height: 12),
            if (appleEnabled)
              ElevatedButton(
                onPressed: () => _oauthLogin(Provider.apple),
                child: const Text('Sign in with Apple'),
              ),
          ],
        ),
      ),
      floatingActionButton: supa.auth.currentSession != null
          ? FloatingActionButton(
              onPressed: _signOut,
              child: const Icon(Icons.logout),
            )
          : null,
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}

class GlowingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const GlowingButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(onPressed: onPressed, child: child),
    );
  }
}
 
