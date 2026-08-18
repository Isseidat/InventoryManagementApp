import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String username, String password);
  Future<void> logout();
  Future<AuthUser?> getCachedUser();
}
