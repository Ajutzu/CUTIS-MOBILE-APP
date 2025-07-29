import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_styles.dart';
import '../../routes/skin_detection_service.dart';
import 'skin_analysis_result.dart';

class SkinDetectionPage extends StatefulWidget {
  const SkinDetectionPage({super.key});

  @override
  State<SkinDetectionPage> createState() => _SkinDetectionPageState();
}

class _SkinDetectionPageState extends State<SkinDetectionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  SkinDetectionResult? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [Permission.camera, Permission.photos].request();

    if (statuses[Permission.camera] != PermissionStatus.granted) {
      if (mounted) {
        _showSnack('Camera permission denied');
      }
      return;
    }

    await Geolocator.requestPermission();
  }

  Future<void> _capture() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) return; // User cancelled.

      setState(() {
        _capturedImage = File(file.path);
        _loading = true;
        _result = null;
      });

      // Fetch current coordinates if allowed.
      String location = 'Singapore';
      try {
        final perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition();
          location = '${pos.latitude},${pos.longitude}';
        }
      } catch (_) {}

      final res = await SkinDetectionService.analyzeSkin(
        imageFile: File(file.path),
        location: location,
      );

      if (!mounted) return;
      setState(() {
        _result = res;
        _loading = false;
      });

      _showResultSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Error capturing image: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showResultSheet() {
    if (_result == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SkinAnalysisResultSheet(result: _result!),
    );
  }

  Widget _buildInstructionScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                48,
          ),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 20),

              // Main illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Skin Detection',
                style: AppTextStyles.h4Bold.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Take a photo of your skin and get AI-powered analysis with personalized recommendations.',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep(
                      number: '1',
                      text: 'Click the capture button below',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      number: '2',
                      text: 'Wait for AI analysis to complete',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      number: '3',
                      text: 'Review the detailed results',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      number: '4',
                      text: 'Ask AI for personalized insights',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loading ? null : _capture,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.camera_alt, size: 24),
                  label: Text(
                    _loading ? 'Processing...' : 'Start Capture',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _capturedImage == null
          ? _buildInstructionScreen()
          : Stack(
              children: [
                // Full screen image
                Positioned.fill(
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                ),
                // Overlay with retake button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _capturedImage = null;
                                  _result = null;
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            if (_loading)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Analyzing...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _capturedImage != null
          ? FloatingActionButton.extended(
              onPressed: _loading ? null : _capture,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_loading ? 'Processing...' : 'Retake'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
