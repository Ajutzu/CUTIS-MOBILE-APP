import 'package:dio/dio.dart';
import 'api.dart';

class SessionResponse {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;

  SessionResponse({
    required this.isAuthenticated,
    this.user,
    this.error,
  });
}

class SessionService {
  SessionService();
  static final _dio = Api().dio;

  Future<SessionResponse> getSession() async {
    try {
      final res = await _dio.get('/api/token/session-management');
      return SessionResponse(isAuthenticated: true, user: res.data['user']);
    } catch (e) {
      return SessionResponse(isAuthenticated: false, error: 'Failed to validate session');
    }
  }

  Future<SessionResponse> refreshSession() async {
    try {
      final res = await _dio.get('/api/token/session-management', queryParameters: {
        '_': DateTime.now().millisecondsSinceEpoch,
      }, options: Options(headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      }));
      return SessionResponse(isAuthenticated: true, user: res.data['user']);
    } catch (e) {
      return SessionResponse(isAuthenticated: false, error: 'Failed to refresh session');
    }
  }
}
