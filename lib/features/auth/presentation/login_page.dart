import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedSwitcher(
              key: const ValueKey('slogan-switcher'),
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isLogin ? 'Welcome' : 'Join',
                key: ValueKey(_isLogin ? 'login_slogan' : 'signup_slogan'),
              ),
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || !v.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Password too short';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_formKey.currentState?.validate() ?? false)
                  ? () {}
                  : null,
              child: Text(_isLogin ? 'Sign in' : 'Create account'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(_isLogin ? 'Create account' : 'Have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
