import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient(AuthInterceptor authInterceptor) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // Thêm Interceptor nhét Token
    _dio.interceptors.add(authInterceptor);

    // In log Request/Response ra Console nếu đang ở chế độ Debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Dio get dio => _dio;
}
