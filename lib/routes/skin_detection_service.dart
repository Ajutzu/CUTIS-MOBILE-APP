import 'dart:io';

import 'package:dio/dio.dart';
import 'api.dart';

class SkinDetectionResult {
  final List<dynamic> predictions;
  final bool success;
  final String? imageUrl;
  final String? recommendation;
  final String? confidence;
  final String? severity;
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
    final preds = (json['predictions'] ?? []) as List<dynamic>;
    // If top-level confidence absent, derive from first prediction
    String? confidence = json['confidence'] as String?;
    if (confidence == null && preds.isNotEmpty) {
      final dynamic c = preds.first;
      if (c is Map && c['confidence'] != null) {
        confidence = c['confidence'].toString();
      }
    }

    return SkinDetectionResult(
      predictions: preds,
      success: json['success'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      recommendation: json['recommendation'] as String?,
      confidence: confidence,
      severity: json['severity'] as String? ?? 'Unknown',
      medicalHistoryAdded: json['medicalHistoryAdded'] as bool? ?? false,
      conditionFound: json['conditionFound'] as bool? ?? false,
      specialists: (json['specialists'] ?? []) as List<dynamic>,
      clinics: (json['clinics'] ?? []) as List<dynamic>,
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
