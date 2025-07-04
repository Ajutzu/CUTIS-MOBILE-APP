import 'package:dio/dio.dart';
import 'api.dart';

class UserService {
  UserService();

  Dio get _dio => Api().dio;

  /// Update user profile. Returns success flag and message.
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      await Api.init();
      final body = {
        'name': name,
        'email': email,
      };
      if (currentPassword != null && newPassword != null) {
        body['currentPassword'] = currentPassword;
        body['newPassword'] = newPassword;
      }
      final res = await _dio.post('/api/user/update-account', data: body);
      if (res.statusCode != null && res.statusCode! < 400) {
        final map = res.data is Map<String, dynamic> ? Map<String, dynamic>.from(res.data) : <String, dynamic>{};
        map['success'] = map['success'] ?? true; // ensure success flag present
        return map;
      }
      return {'success': false, 'message': res.data is Map ? res.data['message'] ?? 'Unexpected error' : 'Unexpected error'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
