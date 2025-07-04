import 'dart:io';

import 'package:dio/dio.dart';
import 'api.dart';

class SkinDetectionResult {
  final List<dynamic> predictions;
  final bool success;
  final String imageUrl;
  final String recommendation;
  final String confidence;
  final String severity;
  final bool medicalHistoryAdded;
  final bool conditionFound;
  final List<dynamic> specialists;
  final List<dynamic> clinics;

  SkinDetectionResult({
    required this.predictions,
    required this.success,
    required this.imageUrl,
    required this.recommendation,
    required this.confidence,
    required this.severity,
    required this.medicalHistoryAdded,
    required this.conditionFound,
    required this.specialists,
    required this.clinics,
  });

  factory SkinDetectionResult.fromJson(Map<String, dynamic> json) {
    return SkinDetectionResult(
      predictions: json['predictions'] as List<dynamic>,
      success: json['success'] as bool,
      imageUrl: json['imageUrl'] as String,
      recommendation: json['recommendation'] as String,
      confidence: json['confidence'] as String,
      severity: json['severity'] as String,
      medicalHistoryAdded: json['medicalHistoryAdded'] as bool,
      conditionFound: json['conditionFound'] as bool,
      specialists: json['specialists'] as List<dynamic>,
      clinics: json['clinics'] as List<dynamic>,
    );
  }
}

class SkinDetectionService {
  SkinDetectionService._();
  static final _dio = Api().dio;

  static Future<SkinDetectionResult> analyzeSkin({
    required File imageFile,
    String location = 'Singapore',
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
      'location': location,
    });

    final res = await _dio.post('/api/ai/classify', data: formData);
    return SkinDetectionResult.fromJson(res.data as Map<String, dynamic>);
  }
}
