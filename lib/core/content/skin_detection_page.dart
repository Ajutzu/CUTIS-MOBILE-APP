import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/skin_detection_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_styles.dart';

class SkinDetectionPage extends StatefulWidget {
  const SkinDetectionPage({Key? key}) : super(key: key);

  @override
  _SkinDetectionPageState createState() => _SkinDetectionPageState();
}

enum PageState { initial, loading, results }

class _SkinDetectionPageState extends State<SkinDetectionPage> {
  PageState _pageState = PageState.initial;
  File? _imageFile;
  Map<String, dynamic>? _analysisResult;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _pageState = PageState.loading;
      });

      try {
        final result = await SkinDetectionService.analyzeSkin(imageFile: _imageFile!);
        setState(() {
          _analysisResult = {
            'image': _imageFile,
            'diagnosis': 'AI-detected skin condition: \\${result.predictions.isNotEmpty ? result.predictions.first['class'] : 'Unknown'}',
            'severity': result.severity,
            'date': DateTime.now(),
            'recordId': 'result',
            'treatment_recommendation': result.recommendation,
            'specialist': (result.specialists.isNotEmpty)
                ? {
                    'name': result.specialists.first['name'],
                    'type': result.specialists.first['specialty'] ?? 'Dermatologist',
                  }
                : {'name': 'N/A', 'type': 'Dermatologist'},
            'clinics': result.clinics
                .map((c) => {
                      'name': c['title'] ?? c['name'],
                      'address': c['snippet'] ?? c['address'] ?? '',
                    })
                .toList(),
          };
          _pageState = PageState.results;
        });
      } catch (e) {
        setState(() => _pageState = PageState.initial);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _resetPage() {
    setState(() {
      _pageState = PageState.initial;
      _imageFile = null;
      _analysisResult = null;
    });
  }

  
    

      


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_pageState) {
      case PageState.initial:
        return _buildInitialView();
      case PageState.loading:
        return _buildLoadingView();
      case PageState.results:
        return _buildResultsView();
    }
  }

  Widget _buildInitialView() {
    return Center(
      key: const ValueKey('initial'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text('Ready to scan your skin?', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Scan Skin Condition', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          const Text('Analyzing...', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _imageFile!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final record = _analysisResult!;
    final date = record['date'] as DateTime;
    final formattedDate = DateFormat("MMMM d, y 'at' h:mm a").format(date);
    final specialist = record['specialist'] as Map<String, dynamic>;
    final clinics = record['clinics'] as List<dynamic>;

    return ListView(
      key: const ValueKey('results'),
      padding: const EdgeInsets.all(16),
      children: [
        Text('Analysis Complete', style: AppTextStyles.title.copyWith(fontSize: 28)),
        const SizedBox(height: 16),
        _buildInfoCard(record, formattedDate),
        const SizedBox(height: 16),
        _buildSectionHeader('Recommended Specialist'),
        _buildSpecialistCard(specialist),
        const SizedBox(height: 16),
        _buildSectionHeader('Nearby Specialized Clinics'),
        ...clinics.map((clinic) => _buildClinicCard(clinic)).toList(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Scan Again', style: AppTextStyles.button),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> record, String formattedDate) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: AppColors.secondary,
      surfaceTintColor: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (record['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(record['image'], height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.medical_services_outlined, 'Diagnosed Condition', record['diagnosis']),
            _buildDetailRow(Icons.warning_amber_outlined, 'Severity', record['severity']),
            _buildDetailRow(Icons.calendar_today_outlined, 'Diagnosis Date', formattedDate),
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
      surfaceTintColor: AppColors.secondary,
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
}
