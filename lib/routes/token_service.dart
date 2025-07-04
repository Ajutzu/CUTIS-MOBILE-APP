import 'api.dart';

class TokenService {
  TokenService._();
  static final _dio = Api().dio;

  /// GET /api/token/check-reset-token
  Future<bool> checkResetToken() async {
    final res = await _dio.get('/api/token/check-reset-token');
    return res.statusCode == 200;
  }

  /// GET /api/token/logout
  Future<bool> logout() async {
    final res = await _dio.get('/api/token/logout');
    return res.statusCode == 200;
  }
}
