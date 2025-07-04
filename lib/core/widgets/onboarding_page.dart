import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 300,
          ),
          const SizedBox(height: 48.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
