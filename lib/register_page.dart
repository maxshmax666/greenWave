import 'dart:async';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<LinearGradient> _bgAnimation;
  late Duration _sloganInterval;
  int _sloganIndex = 0;
  bool _started = false;

  final _slogans = const [
    'Добро пожаловать',
    'Экономьте время',
    'Будьте безопасны',
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this);
    _bgAnimation = TweenSequence<LinearGradient>([
      TweenSequenceItem(
        weight: 1,
        tween: Tween(
          begin: const LinearGradient(colors: [Colors.green, Colors.blue]),
          end: const LinearGradient(colors: [Colors.blue, Colors.purple]),
        ),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: Tween(
          begin: const LinearGradient(colors: [Colors.blue, Colors.purple]),
          end: const LinearGradient(colors: [Colors.purple, Colors.red]),
        ),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: Tween(
          begin: const LinearGradient(colors: [Colors.purple, Colors.red]),
          end: const LinearGradient(colors: [Colors.red, Colors.green]),
        ),
      ),
    ]).animate(_bgController);
  }

  void _configureAnimations() {
    final disable = MediaQuery.of(context).disableAnimations;
    _bgController
      ..duration =
          disable ? const Duration(seconds: 5) : const Duration(seconds: 20)
      ..repeat();
    _sloganInterval =
        disable ? const Duration(seconds: 1) : const Duration(seconds: 3);
  }

  Future<void> _cycleSlogans() async {
  // wait a frame to avoid setState during build
    while (mounted) {
      await Future.delayed(_sloganInterval);
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 80));
      setState(() => _sloganIndex = (_sloganIndex + 1) % _slogans.length);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureAnimations();
    if (!_started) {
      _started = true;
      _cycleSlogans();
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Row(
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return Container(
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: _bgAnimation.value,
                    boxShadow: disable
                        ? null
                        : const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: disable
                          ? const Duration(milliseconds: 200)
                          : const Duration(milliseconds: 700),
                      transitionBuilder: (child, anim) {
                        final offsetAnim = Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero)
                            .animate(anim);
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: offsetAnim,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _slogans[_sloganIndex],
                        key: ValueKey(_sloganIndex),
                        style: textTheme.headlineSmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Registration form placeholder',
                style: textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

