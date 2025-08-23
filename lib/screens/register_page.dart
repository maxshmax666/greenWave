import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/analytics/analytics.dart';

final supa = Supabase.instance.client;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              child: Text(isLogin ? 'Create account' : 'I have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
