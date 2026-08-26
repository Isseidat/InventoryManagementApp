import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network/auth_interceptor.dart';
import 'network/dio_client.dart';
import 'utils/shared_prefs_helper.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/dashboard/dashboard_bloc.dart';
import '../presentation/blocs/product/product_bloc.dart';
import '../presentation/blocs/transaction/transaction_bloc.dart';
import '../presentation/blocs/staff/staff_bloc.dart';
import '../core/theme/theme_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. Khởi tạo SharedPreferences (External)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // 2. Utils
  sl.registerLazySingleton(() => SharedPrefsHelper(sl()));

  // 3. Network
  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));

  // 4. Data Sources (Sẽ thêm sau)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  
  // 5. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sharedPrefsHelper: sl(),
    ),
  );

  // 6. BLoCs
  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => DashboardBloc(dio: sl<DioClient>().dio));
  sl.registerFactory(() => ProductBloc(dio: sl<DioClient>().dio));
  sl.registerFactory(() => TransactionBloc(dio: sl<DioClient>().dio));
  sl.registerFactory(() => StaffBloc(dio: sl<DioClient>().dio));

  // 7. Theme
  sl.registerLazySingleton(() => ThemeCubit());
}
