import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/layouts/main_layout.dart';

import 'go_router_refresh_stream.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (authState is AuthInitial || authState is AuthLoading) {
        // Đang chờ check trạng thái (khi mới mở app)
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isGoingToLogin) {
        // Chưa đăng nhập mà rớ tới trang khác -> Đá về login
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        // Đã đăng nhập mà cố vào login -> Đá vô Home
        return '/home';
      }

      return null; // Không cần điều hướng
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
    ],
  );
}
