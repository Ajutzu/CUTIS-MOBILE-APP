import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../theme/app_styles.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>?) onNavigateToAskAi;
  final VoidCallback onBack;
  final VoidCallback onFindSpecialists;

  const HistoryDetailPage({
    Key? key,
    required this.record,
    required this.onNavigateToAskAi,
    required this.onBack,
    required this.onFindSpecialists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final condition = record['condition'] ?? {};
    final diagnosis = condition['name'] ?? record['diagnosis'] ?? 'Unknown';
    final severity = condition['severity'] ?? record['severity'] ?? 'Unknown';
    final dateStr = record['diagnosis_date'] ?? record['date'];
    final date = dateStr is String
        ? DateTime.tryParse(dateStr)
        : (dateStr as DateTime?);
    final formattedDate = date != null
        ? DateFormat("MMMM d, y 'at' h:mm a").format(date)
        : 'Unknown';
    final treatment =
        record['treatment_recommendation'] ??
        condition['recommendation'] ??
        'N/A';
    final recordId = record['_id'] ?? record['recordId'] ?? 'N/A';
    final imageUrl = record['upload_skin'] ?? record['image'];
    final specialists = record['specialists'] != null
        ? record['specialists']
        : (record['specialist'] != null ? [record['specialist']] : []);
    final clinics = record['clinics'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: onBack,
        ),
        title: Text('Record Details', style: AppTextStyles.heading),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (imageUrl != null)
            _buildImage(imageUrl),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            diagnosis,
            severity,
            formattedDate,
            recordId,
            treatment,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Recommended Specialists'),
          specialists.isNotEmpty
              ? Column(
                  children: [
                    for (var s in specialists) _buildSpecialistCard(s),
                  ],
                )
              : _buildEmptyState('No specialists found for this condition.', 'Find Specialists', onFindSpecialists),
          const SizedBox(height: 16),
          _buildSectionHeader('Nearby Specialized Clinics'),
          clinics.isNotEmpty
              ? Column(
                  children: [
                    for (var clinic in clinics) _buildClinicCard(clinic),
                  ],
                )
              : _buildEmptyState('No clinics found nearby.', null, null),
        ],
      ),
      bottomNavigationBar: _buildAskAIButton(record),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 250,
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: AppColors.primary.withOpacity(0.7), size: 48),
                const SizedBox(height: 8),
                Text('Image not available', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String diagnosis,
    String severity,
    String formattedDate,
    String recordId,
    String treatment,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: AppColors.secondary,
      surfaceTintColor: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text('Diagnosis Details', 
                  style: AppTextStyles.heading.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.medical_services_outlined, 'Diagnosis', diagnosis),
            _buildDetailRow(Icons.warning_amber_rounded, 'Severity', severity),
            _buildDetailRow(Icons.calendar_today_outlined, 'Date', formattedDate),
            _buildDetailRow(Icons.article_outlined, 'Record ID', recordId),
            _buildTreatmentRecommendation(treatment),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // reduced from 16
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary), // reduced from 24
          const SizedBox(width: 12), // reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.text.withOpacity(0.6),
                    fontSize: 12, // reduced from 14
                  )),
                const SizedBox(height: 2), // reduced from 4
                Text(value, 
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w500, // reduced from w600
                    fontSize: 14, // reduced from 16
                  )),
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
      child: Text(title, style: AppTextStyles.heading),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> specialist) {
    final link = specialist['link'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: link != null && link.isNotEmpty ? () => _launchURL(link) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(specialist['name'] ?? 'N/A', 
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                      const SizedBox(height: 4),
                      Text(specialist['specialty'] ?? 'N/A',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.text.withOpacity(0.6),
                          fontSize: 14,
                        )),
                    ],
                  ),
                ),
                if (link != null && link.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    final link = clinic['link'] as String?;
    return GestureDetector(
      onTap: () {
        if (link != null && link.isNotEmpty) {
          _launchURL(link);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinic['name'] ?? 'N/A', style: AppTextStyles.subtitle),
                    Text(clinic['address'] ?? 'N/A', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              if (link != null && link.isNotEmpty)
                const Icon(Icons.open_in_new, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, String? buttonText, VoidCallback? onPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary.withOpacity(0.7), size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.text.withOpacity(0.8)),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(buttonText, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAskAIButton(Map<String, dynamic> record) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => onNavigateToAskAi(record),
        icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
        label: Text('Ask AI for Insights', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildTreatmentRecommendation(String treatment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // reduced from 6
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.healing_outlined, color: AppColors.primary, size: 18), // reduced from 20
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treatment Recommendation', 
                  style: AppTextStyles.subtitle.copyWith(fontSize: 12)), // added fontSize
                const SizedBox(height: 2),
                Linkify(
                  onOpen: (link) => _launchURL(link.url),
                  text: treatment,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 13, // added smaller fontSize
                    color: Colors.black87
                  ),
                  linkStyle: AppTextStyles.link.copyWith(fontSize: 13), // matched fontSize
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }
}
