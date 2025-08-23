import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late final AnimationController _sloganController;
  late final AnimationController _gradientController;
  late final Animation<LinearGradient> _bgAnimation;
  final slogans = <String>[
    'Слоган первый',
    'Слоган второй',
    'Слоган третий',
    'Слоган четвертый',
  ];
  late final int _sloganCount = slogans.length;

  @override
  void initState() {
    super.initState();
    _sloganController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4 * _sloganCount),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final gradients = <LinearGradient>[
      const LinearGradient(colors: [Colors.blue, Colors.purple]),
      const LinearGradient(colors: [Colors.purple, Colors.pink]),
      const LinearGradient(colors: [Colors.pink, Colors.orange]),
      const LinearGradient(colors: [Colors.orange, Colors.blue]),
    ];

    _bgAnimation = TweenSequence<LinearGradient>([
      TweenSequenceItem(
        tween: Tween(begin: gradients[0], end: gradients[1]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: gradients[1], end: gradients[2]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: gradients[2], end: gradients[3]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: gradients[3], end: gradients[0]),
        weight: 1,
      ),
    ]).animate(_gradientController);
  }

  @override
  void dispose() {
    _sloganController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final gradient = _bgAnimation.value;
        return Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Center(
            child: AnimatedBuilder(
              animation: _sloganController,
              builder: (_, __) {
                final index =
                    (_sloganController.value * _sloganCount).floor() % _sloganCount;
                return Text(
                  slogans[index],
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

