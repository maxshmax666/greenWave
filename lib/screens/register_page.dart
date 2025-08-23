import 'package:flutter/material.dart';

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

