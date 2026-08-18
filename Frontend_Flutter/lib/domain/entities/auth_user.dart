import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String token;
  final String fullName;
  final String roleName;
  final String? jobTitle;

  const AuthUser({
    required this.token,
    required this.fullName,
    required this.roleName,
    this.jobTitle,
  });

  @override
  List<Object?> get props => [token, fullName, roleName, jobTitle];
}
