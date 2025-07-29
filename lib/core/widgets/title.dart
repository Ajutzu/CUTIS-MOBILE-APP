import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

/// A reusable section title consisting of a small badge pill and a two-line
/// heading. Example design matches the onboarding screenshots.
class SectionTitle extends StatelessWidget {
  /// Small pill text shown above the title.
  final String badgeText;

  /// First and second lines of the title. The first line is rendered in default
  /// text color, the second line in [AppColors.primary] to create visual
  /// emphasis similar to the reference design.
  final String line1;

  const SectionTitle({
    Key? key,
    required this.badgeText,
    required this.line1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                badgeText,
                style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Title lines
        Text(
          line1,
          style: AppTextStyles.heading.copyWith(fontSize: 32, color: AppColors.text),
        ),
      ],
    );
  }
}
