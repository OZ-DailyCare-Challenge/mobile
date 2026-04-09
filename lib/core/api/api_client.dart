import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';

/// SharedPreferences 키 상수
abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String user = 'user';
}

/// Dio 인스턴스 Provider
/// 웹 저장소(src/api/axios.ts) 기준으로 작성
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
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── 인터셉터 등록 ────────────────────────────────
    _dio.interceptors.addAll([
      _AuthInterceptor(),   // Bearer 토큰 자동 주입
      _LogInterceptor(),    // 요청/응답 로그 (개발용)
    ]);
  }

  Dio get dio => _dio;

  // ── 편의 메서드 ──────────────────────────────────
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

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

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);
}

/// Bearer 토큰 자동 주입 인터셉터
/// 웹: axios.ts의 request interceptor 대응
class _AuthInterceptor extends Interceptor {
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
    // 401: 토큰 만료 → 로그인 페이지로 유도 (추후 리프레시 로직 추가)
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.accessToken);
      await prefs.remove(StorageKeys.user);
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
    print('[API] ✗ ${err.response?.statusCode} ${err.requestOptions.path} — ${err.message}');
    handler.next(err);
  }
}
