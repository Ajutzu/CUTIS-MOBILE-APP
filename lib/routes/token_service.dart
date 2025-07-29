import 'api.dart';

class TokenService {
  TokenService._internal();
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;

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
