import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          child: Image.asset(record['image'], width: 60, height: 60, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record['diagnosis'].split(': ').last,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildSeverityBadge(record['severity']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final date = record['date'] as DateTime;
    final formattedDate = DateFormat('MMMM d, y').format(date);
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

  Widget _buildSeverityBadge(String severity) {
    Color badgeColor;
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'high':
        badgeColor = Colors.red.shade400;
        break;
      case 'moderate':
        badgeColor = Colors.orange.shade400;
        break;
      default:
        badgeColor = Colors.green.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(fontSize: 12, color: badgeColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
