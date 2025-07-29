import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_styles.dart';

class HistoryRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>?) onNavigateToAskAi;
  final Function(Map<String, dynamic>) onShowDetail;

  const HistoryRecordCard({
    Key? key,
    required this.record,
    required this.onNavigateToAskAi,
    required this.onShowDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: AppColors.secondary,
      child: InkWell(
        onTap: () => onShowDetail(record),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              const Divider(),
              _buildRecommendations(),
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            record['image'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record['diagnosis'],
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, y - h:mm a').format(record['date']),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(record['severity']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record['severity'],
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final formattedDate = DateFormat('MMM d, y').format(record['date']);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $formattedDate', style: TextStyle(fontSize: 12, color: AppColors.text)),
            const SizedBox(height: 4),
            Text('ID: ${record['recordId']}', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.text)),
          ],
        ),
        const Icon(Icons.chevron_right, color: AppColors.primary),
      ],
    );
  }

  Widget _buildRecommendations() {
    final specialist = record['specialist'] as Map<String, dynamic>?;
    final clinics = record['clinics'] as List<dynamic>?; // This is currently empty

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (specialist != null && specialist['name'] != null)
          _buildRecommendationLink(
            icon: Icons.person_search,
            title: 'Find a Specialist',
            subtitle: 'Search for "${specialist['name']}"',
            onTap: () {
              final query = Uri.encodeComponent('${specialist['name']}, ${specialist['type']}');
              _launchURL('https://www.google.com/search?q=$query');
            },
          ),
        if (clinics != null && clinics.isNotEmpty)
          _buildRecommendationLink(
            icon: Icons.local_hospital,
            title: 'Find a Clinic',
            subtitle: 'Search for nearby clinics',
            onTap: () {
              _launchURL('https://www.google.com/maps/search/dermatology+clinic');
            },
          ),
        if ((specialist != null && specialist['name'] != null) || (clinics != null && clinics.isNotEmpty))
          const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecommendationLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.launch, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // For now, we just print to console if it fails.
      // In a real app, you might want to show a snackbar.
      print('Could not launch $url');
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'high':
        return Colors.red.shade400;
      case 'moderate':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }
}
