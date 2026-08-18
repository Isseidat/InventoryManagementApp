import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<bool> {
  /// state = true → Dark mode, false → Light mode
  ThemeCubit() : super(true); // Dark mode mặc định như ảnh Vela

  void toggleTheme() => emit(!state);
  void setDark() => emit(true);
  void setLight() => emit(false);

  bool get isDark => state;
}
