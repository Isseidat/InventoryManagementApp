import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/service_locator.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_event.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/product/product_event.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';
import 'presentation/blocs/transaction/transaction_event.dart';
import 'presentation/blocs/staff/staff_bloc.dart';
import 'presentation/blocs/staff/staff_event.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(di.sl<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (_) => di.sl<DashboardBloc>()..add(DashboardSummaryRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<ProductBloc>()..add(ProductListRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<TransactionBloc>()..add(TransactionListRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<StaffBloc>()..add(StaffListRequested()),
        ),
        BlocProvider.value(
          value: di.sl<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return Theme(
            data: isDark ? AppTheme.dark : AppTheme.light,
            child: MaterialApp.router(
              title: 'InventoryPro',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              themeAnimationDuration: Duration.zero,
              routerConfig: _appRouter.router,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
