import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_styles.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>?) onNavigateToAskAi;
  final VoidCallback onBack;

  const HistoryDetailPage({
    Key? key,
    required this.record,
    required this.onNavigateToAskAi,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = record['date'] as DateTime;
    final formattedDate = DateFormat("MMMM d, y 'at' h:mm a").format(date);
    final specialist = record['specialist'] as Map<String, dynamic>;
    final clinics = record['clinics'] as List<dynamic>;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildInfoCard(context, formattedDate),
          const SizedBox(height: 16),
          _buildSectionHeader('Recommended Specialist'),
          _buildSpecialistCard(specialist),
          const SizedBox(height: 16),
          _buildSectionHeader('Nearby Specialized Clinics'),
          ...clinics.map((clinic) => _buildClinicCard(clinic)).toList(),
        ],
      ),
      bottomNavigationBar: _buildAskAIButton(context),
    );
  }

  Widget _buildInfoCard(BuildContext context, String formattedDate) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: AppColors.secondary,
      surfaceTintColor: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(Icons.medical_services_outlined, 'Diagnosed Condition', record['diagnosis']),
            _buildDetailRow(Icons.warning_amber_outlined, 'Severity', record['severity']),
            _buildDetailRow(Icons.calendar_today_outlined, 'Diagnosis Date', formattedDate),
            _buildDetailRow(Icons.article_outlined, 'Record ID', record['recordId']),
            _buildDetailRow(Icons.healing_outlined, 'Treatment Recommendation', record['treatment_recommendation']),
          ],
        ),
      ),
    );
  }


  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 14, color: AppColors.primary.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> specialist) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: AppColors.secondary,
      surfaceTintColor: AppColors.secondary,
      child: ListTile(
        leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.person_outline, color: AppColors.primary),
      ),
        title: Text(specialist['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(specialist['type']),
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.secondary,
      child: ListTile(
        leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.local_hospital_outlined, color: AppColors.primary),
      ),
        title: Text(clinic['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(clinic['address']),
      ),
    );
  }

  Widget _buildAskAIButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => onNavigateToAskAi(record),
        icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
        label: const Text('Ask AI for Insights', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
