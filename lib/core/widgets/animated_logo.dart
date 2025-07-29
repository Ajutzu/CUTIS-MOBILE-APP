import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  final double width;
  const AnimatedLogo({super.key, this.width = 300});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(0.5),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Image.asset(
          'assets/images/Cutis.png',
          fit: BoxFit.contain,
          width: widget.width,
        ),
      ),
    );
  }
}
