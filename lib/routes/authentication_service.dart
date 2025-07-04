import 'package:dio/dio.dart';
import 'api.dart';

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: json['user'] as Map<String, dynamic>?,
      token: json['token'] as String?,
    );
  }
}

class AuthenticationService {
  AuthenticationService();
  // Retrieve Dio instance dynamically after ensuring Api is initialized
  Dio get _dio => Api().dio;

  Future<AuthResponse> login({required String email, required String password}) async {
    try {
      await Api.init();
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (res.statusCode != null && res.statusCode! < 400) {
        // Treat any 2xx/3xx response as success.
        if (res.data is Map<String, dynamic>) {
          final map = res.data as Map<String, dynamic>;
          return AuthResponse(
            success: true,
            message: map['message'] as String? ?? '',
            user: map['user'] as Map<String, dynamic>?,
            token: map['token'] as String?,
          );
        }
        return AuthResponse(success: true, message: 'Login Successfully');
      }
      // Non-success HTTP codes (e.g., 400) should be treated as failure.
      final errMsg = (res.data is Map<String, dynamic>) ? (res.data['message'] as String? ?? 'Login failed') : 'Login failed';
      return AuthResponse(success: false, message: errMsg);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      final message = e.response?.data?['message'] as String? ?? e.response?.data.toString() ?? 'A network error occurred.';
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return AuthResponse(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<AuthResponse> googleLogin(String credential) async {
    try {
      await Api.init();
      final dio = Api().dio;
      final res = await dio.post('/api/auth/google-oauth', data: {
        'token': credential,
      });
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      return AuthResponse(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await Api.init();
      final dio = Api().dio;
      final res = await dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'User',
      });

      if (res.statusCode != null && res.statusCode! < 400) {
        if (res.data is Map<String, dynamic>) {
          final map = res.data as Map<String, dynamic>;
          return AuthResponse(
            success: true,
            message: map['message'] as String? ?? 'Signup successful',
            user: map['user'] as Map<String, dynamic>?,
            token: map['token'] as String?,
          );
        }
        return AuthResponse(success: true, message: 'Signup successful');
      }

      // failure
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final errMsg = map['message'] as String? ?? map['error'] as String? ?? 'Signup failed';
        return AuthResponse(success: false, message: errMsg);
      }
      return AuthResponse(success: false, message: 'Signup failed');
    } catch (e) {
      return AuthResponse(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  // Legacy alias used by old UI code
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) => register(name: name, email: email, password: password);

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await Api.init();
      final dio = Api().dio;
      final res = await dio.post('/api/auth/forgot-password', data: {
        'email': email,
      });
      return res.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      await Api.init();
      final dio = Api().dio;
      final res = await dio.post('/api/auth/verify-otp', data: {
        'otp': otp,
      });
      final data = Map<String, dynamic>.from(res.data);
      data.putIfAbsent('success', () => res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      await Api.init();
      final dio = Api().dio;
      final res = await dio.post('/api/auth/update-password', data: {
        'newPassword': newPassword,
      });
      final data = Map<String, dynamic>.from(res.data);
      data.putIfAbsent('success', () => res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }
}
