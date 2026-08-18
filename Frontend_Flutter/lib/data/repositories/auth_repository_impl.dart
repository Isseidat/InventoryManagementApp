import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../core/utils/shared_prefs_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPrefsHelper sharedPrefsHelper;

  static AuthUser? _inMemoryUser; // Lưu toàn bộ user object trên RAM

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPrefsHelper,
  });

  @override
  Future<AuthUser> login(String username, String password) async {
    final user = await remoteDataSource.login(username, password);
    
    // Lưu vào RAM
    _inMemoryUser = user;
    await sharedPrefsHelper.saveToken(user.token);
    await sharedPrefsHelper.saveRole(user.roleName);
    
    return user;
  }

  @override
  Future<void> logout() async {
    _inMemoryUser = null;
    await sharedPrefsHelper.clearToken();
  }

  @override
  Future<AuthUser?> getCachedUser() async {
    // Chỉ đọc từ RAM, tắt app là null, bắt buộc login lại
    return _inMemoryUser;
  }
}
