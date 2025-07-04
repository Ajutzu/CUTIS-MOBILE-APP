import 'package:flutter/material.dart';
import 'animated_logo.dart';
import '../theme/app_styles.dart';

class LoadingAnimation extends StatelessWidget {
  final String placeholderUrl;
  const LoadingAnimation({
    Key? key,
    this.placeholderUrl = 'assets/images/Cutis.png'
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _LoadingImage(),
      ),
    );
  }
}

class _LoadingImage extends StatelessWidget {
  const _LoadingImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedLogo(width: 200);
  }
}

