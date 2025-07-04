import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Global Dio wrapper that automatically persists cookies.
/// Usage: `final dio = Api().dio;`
class Api {
  Api._internal();
  static final Api _instance = Api._internal();
  factory Api() => _instance;

  late final Dio dio;
  late final PersistCookieJar cookieJar;
  bool _initialized = false;

  /// Ensure [dio] is ready. Call this before making requests in `main()`.
  static Future<void> init() async => _instance._init();

  Future<void> _init() async {
    if (_initialized) return;

    // Determine a sensible default API origin when the compile-time environment
    // variable `API_ORIGIN` is not provided. For Android emulators the host
    // machine is accessible via 10.0.2.2, whereas for Flutter Web we can usually
    // talk to the backend running on the same origin.
    final String defaultOrigin = kIsWeb ? 'http://localhost:3002' : 'http://10.0.2.2:3002';

    // Allow overriding the origin via `--dart-define=API_ORIGIN=<url>`.
    final String envOrigin = const String.fromEnvironment('API_ORIGIN');
    final String resolvedOrigin = (envOrigin.isNotEmpty) ? envOrigin : defaultOrigin;

    dio = Dio(
      BaseOptions(
        baseUrl: resolvedOrigin,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        extra: {
          // make Dio attach stored cookies automatically
          'withCredentials': true,
        },
        headers: {
          'Accept': 'application/json',
        },
        // Return responses even for 4xx so we can inspect error bodies instead of
        // throwing DioException immediately. 5xx and network errors will still
        // throw.
        validateStatus: (status) => status != null && status < 500,
      ),
    )..interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));

    if (kIsWeb) {
      // On web, rely on the browser's native cookie handling. `withCredentials` in
      // [BaseOptions] makes the browser attach and store cookies automatically.
      // No explicit CookieManager is necessary here.
    } else {
      final dir = await getApplicationDocumentsDirectory();
      cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
      dio.interceptors.add(CookieManager(cookieJar));
    }

    _initialized = true;
  }
}
