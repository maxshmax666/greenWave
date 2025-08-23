import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/analytics/analytics.dart';

final supa = Supabase.instance.client;


class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const form = _RegisterForm();
        const panel = _RegisterPanel();
        if (width >= 1200) {
          return Row(
            children: [
              SizedBox(width: width * 0.6, child: panel),
              SizedBox(
                width: width * 0.4,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: form,
                  ),
                ),
              ),
            ],
          );
        } else if (width >= 900) {
          return Row(
            children: [
              SizedBox(width: width * 0.5, child: panel),
              SizedBox(
                width: width * 0.5,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: form,
                  ),
                ),
              ),
            ],
          );
        } else {
          final panelHeight = width < 600 ? 260.0 : 300.0;
          return Column(
            children: [
              SizedBox(
                height: panelHeight,
                width: double.infinity,
                child: panel,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(width: double.infinity, child: form),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: const Center(
        child: Text('Panel', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TextField(decoration: InputDecoration(labelText: 'Email')),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Register')),
      ],
    );
  }
}



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
<
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
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;
  bool _canSubmit = false;
  PasswordStrength _strength = PasswordStrength.weak;

  void _updateStrength(String v) {
    setState(() => _strength = _calcStrength(v));
  }

  PasswordStrength _calcStrength(String v) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
    if (v.length >= 8 && hasLetter && hasDigit) return PasswordStrength.strong;
    if (v.length >= 8) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  void _onChanged() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid != _canSubmit) setState(() => _canSubmit = valid);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте правильность данных')),
      );
      return;
    }
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо принять условия')),
      );
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Аккаунт создан')));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();

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
=======
    final active = _canSubmit && _accepted;
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: _onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите email';
                  final rgx = RegExp('^[^@]+@[^@]+\.[^@]+\$');
                  if (!rgx.hasMatch(v.trim())) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                onChanged: _updateStrength,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  final value = v ?? '';
                  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                  final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                  if (value.length < 8 || !hasLetter || !hasDigit) {
                    return 'Минимум 8 символов, буква и цифра';
                  }
                  return null;
                },
              ),              const SizedBox(height: 8),
              _PasswordStrengthIndicator(strength: _strength),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: const Text('Принимаю условия'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              GlowingButton(
                onPressed: active ? _submit : null,
                child: const Text('Создать аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PasswordStrength { weak, medium, strong }

class _PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;
  const _PasswordStrengthIndicator({required this.strength});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    double value;
    switch (strength) {
      case PasswordStrength.strong:
        color = Colors.green;
        label = 'Сильный';
        value = 1;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        label = 'Средний';
        value = 0.66;
        break;
      case PasswordStrength.weak:
      default:
        color = Colors.red;
        label = 'Слабый';
        value = 0.33;
        break;
    }
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: color.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class GlowingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const GlowingButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        boxShadow: onPressed != null
            ? [BoxShadow(color: primary.withOpacity(0.6), blurRadius: 12)]
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        child: child,
      ),
    );
  }
}


