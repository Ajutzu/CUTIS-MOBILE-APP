import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_styles.dart';
import '../../routes/skin_detection_service.dart';
import 'ask_ai_page.dart';

class SkinAnalysisResultSheet extends StatelessWidget {
  final SkinDetectionResult result;

  const SkinAnalysisResultSheet({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar with more visible touch area
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (_) {},
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Title with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.medical_services_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Analysis Result',
                              style: AppTextStyles.h4Bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Diagnosis
                      if (result.predictions.isNotEmpty)
                        ResultCard(
                          icon: Icons.medical_services_outlined,
                          iconColor: AppColors.primary,
                          title: 'Diagnosis',
                          value: (result.predictions.first['class'] ?? 'Unknown')
                              .toString(),
                        ),
                      if (result.predictions.isNotEmpty)
                        const SizedBox(height: 12),
                      
                      // Result cards
                      ResultCard(
                        icon: result.conditionFound
                            ? Icons.warning_amber
                            : Icons.check_circle_outline,
                        iconColor: result.conditionFound
                            ? Colors.orange
                            : Colors.green,
                        title: 'Condition Found',
                        value: result.conditionFound ? "Yes" : "No",
                      ),
                      const SizedBox(height: 12),

                      ResultCard(
                        icon: Icons.analytics_outlined,
                        iconColor: Colors.blue,
                        title: 'Confidence',
                        value: result.confidence ?? 'N/A',
                      ),
                      const SizedBox(height: 12),

                      ResultCard(
                        icon: Icons.priority_high_outlined,
                        iconColor: _getSeverityColor(result.severity ?? ''),
                        title: 'Severity',
                        value: result.severity ?? 'Unknown',
                      ),
                      const SizedBox(height: 20),

                      // Recommendation section
                      RecommendationCard(recommendation: result.recommendation),
                      const SizedBox(height: 24),

                      // Specialists section
                      if (result.specialists.isNotEmpty) ...[
                        Text(
                          'Recommended Specialists',
                          style: AppTextStyles.bodyBold,
                        ),
                        const SizedBox(height: 8),
                        for (final specialist in result.specialists)
                          SpecialistCard(specialist: specialist),
                        const SizedBox(height: 24),
                      ],

                      // Clinics section
                      if (result.clinics.isNotEmpty) ...[
                        Text(
                          'Nearby Clinics',
                          style: AppTextStyles.bodyBold,
                        ),
                        const SizedBox(height: 8),
                        for (final clinic in result.clinics) 
                          ClinicCard(clinic: clinic),
                        const SizedBox(height: 24),
                      ],

                      // AI Button
                      const SizedBox(height: 16),
                      AskAIButton(result: result),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const ResultCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final String? recommendation;

  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommendation',
                style: AppTextStyles.bodyBold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation ?? 'No recommendation provided.',
            style: AppTextStyles.body.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final dynamic clinic;

  const ClinicCard({
    super.key,
    required this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    final link = clinic['link'] as String?;
    
    return GestureDetector(
      onTap: () {
        if (link != null && link.isNotEmpty) {
          launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(
                Icons.local_hospital,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic['title'] ?? 'Unknown Clinic',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clinic['snippet'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (clinic['location'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          clinic['location'],
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class SpecialistCard extends StatelessWidget {
  final dynamic specialist;

  const SpecialistCard({
    super.key,
    required this.specialist,
  });

  @override
  Widget build(BuildContext context) {
    final link = specialist['link'] as String?;
    
    return GestureDetector(
      onTap: () {
        if (link != null && link.isNotEmpty) {
          launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialist['name'] ?? 'Unknown',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialist['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class AskAIButton extends StatelessWidget {
  final SkinDetectionResult result;

  const AskAIButton({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AskAIPage(
                historyRecord: {
                  'analysis': result.recommendation ?? '',
                  'confidence': result.confidence,
                  'severity': result.severity,
                },
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 20,
        ),
        label: const Text(
          'Ask AI for Insight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}