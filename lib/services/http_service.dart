import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../logger/logger.dart';
import 'api_exception.dart';

class HttpService {
  static HttpService get to => Get.find();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  late final Dio _dio;

  HttpService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger.d('HTTP -> ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.d(
              'HTTP <- ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (e, handler) {
          Logger.w(
              'HTTP x ${e.requestOptions.method} ${e.requestOptions.path} ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _handleResponse<T>(response);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _handleResponse<T>(response);
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _handleResponse<T>(response);
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _handleResponse<T>(response);
  }

  T _handleResponse<T>(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        code: statusCode,
        message:
            'HTTP request failed: $statusCode ${response.statusMessage ?? ''}'
                .trim(),
        httpStatus: statusCode,
      );
    }

    final body = response.data;
    if (body is Map) {
      final map = body.map((key, value) => MapEntry(key.toString(), value));
      final code = _toInt(map['code']);
      if (map.containsKey('code') && code != 0) {
        throw ApiException(
          code: code,
          message: (map['message'] ?? 'business error').toString(),
          httpStatus: statusCode,
          requestId: map['request_id']?.toString(),
        );
      }
      if (map.containsKey('data')) {
        return map['data'] as T;
      }
      return map as T;
    }

    return body as T;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
