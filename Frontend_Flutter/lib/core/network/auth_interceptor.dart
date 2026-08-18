import 'package:dio/dio.dart';
import '../utils/shared_prefs_helper.dart';

class AuthInterceptor extends Interceptor {
  final SharedPrefsHelper _sharedPrefsHelper;

  AuthInterceptor(this._sharedPrefsHelper);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Lấy token từ local storage
    final token = _sharedPrefsHelper.getToken();
    
    // 2. Nếu có token, nhét vào Header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // 3. Đảm bảo format gửi đi là JSON
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Nếu API trả về 401 Unauthorized (Token hết hạn / Không hợp lệ)
    if (err.response?.statusCode == 401) {
      // Tương lai: Có thể xử lý tự động logout hoặc refresh token tại đây
    }
    super.onError(err, handler);
  }
}
