import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';

/// SharedPreferences 키 상수
abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String userId = 'user_id';
  static const String userNickname = 'user_nickname';
}

/// Dio 인스턴스 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient._create();
});

class ApiClient {
  late final Dio _dio;

  ApiClient._create() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 35), // long-poll 대응
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_dio), // Bearer 토큰 자동 주입 + 401 재시도
      _LogInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path,
          queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);
}

/// Bearer 토큰 자동 주입 + 만료 시 토큰 갱신 인터셉터
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // refresh_token은 httponly 쿠키로 자동 전송됨
      _isRefreshing = true;
      try {
        final refreshResp = await _dio.get(Endpoints.tokenRefresh);
        final newToken =
            (refreshResp.data as Map<String, dynamic>)['access_token']
                as String?;
        if (newToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(StorageKeys.accessToken, newToken);

          // 원래 요청 재시도
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryResp = await _dio.fetch(opts);
          _isRefreshing = false;
          return handler.resolve(retryResp);
        }
      } catch (_) {
        // refresh 실패 → 토큰 삭제
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(StorageKeys.accessToken);
        await prefs.remove(StorageKeys.userId);
        await prefs.remove(StorageKeys.userNickname);
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}

/// 요청/응답 로그 인터셉터 (개발 환경용)
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ▶ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ◀ ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print(
        '[API] ✗ ${err.response?.statusCode} ${err.requestOptions.path} — ${err.message}');
    handler.next(err);
  }
}
