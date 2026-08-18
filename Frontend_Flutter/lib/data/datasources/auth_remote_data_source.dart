import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUser> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthUser> login(String username, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['status'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          return AuthUser(
            token: data['token'],
            fullName: data['fullName'] ?? '',
            roleName: data['roleName'] ?? 'User',
            jobTitle: data['jobTitle'],
          );
        }
        throw Exception('Dữ liệu trả về không đúng định dạng');
      } else {
        throw Exception('Lỗi đăng nhập không xác định');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        throw Exception(e.response?.data['message'] ?? 'Sai tài khoản hoặc mật khẩu!');
      }
      throw Exception('Lỗi kết nối máy chủ!');
    }
  }
}
