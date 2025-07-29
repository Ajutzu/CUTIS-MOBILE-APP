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
      final user = res.data['user'];
      final isAuth = user != null;
      return SessionResponse(isAuthenticated: isAuth, user: user, error: isAuth ? null : (res.data['message']?.toString() ?? 'Unauthenticated'));
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
      final user = res.data['user'];
      final isAuth = user != null;
      return SessionResponse(isAuthenticated: isAuth, user: user, error: isAuth ? null : (res.data['message']?.toString() ?? 'Unauthenticated'));
    } catch (e) {
      return SessionResponse(isAuthenticated: false, error: 'Failed to refresh session');
    }
  }
}
