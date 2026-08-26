import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final Dio dio;

  StaffBloc({required this.dio}) : super(StaffInitial()) {
    on<StaffListRequested>(_onListRequested);
    on<StaffCreated>(_onCreated);
    on<StaffUpdated>(_onUpdated);
    on<StaffDeleted>(_onDeleted);
  }

  Future<void> _onListRequested(
      StaffListRequested event, Emitter<StaffState> emit) async {
    emit(StaffLoading());
    try {
      final response = await dio.get('/Users');
      if (response.statusCode == 200) {
        emit(StaffLoaded(response.data ?? []));
      } else {
        emit(StaffFailure('Không thể tải danh sách nhân sự.'));
      }
    } catch (e) {
      emit(StaffFailure('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> _onCreated(
      StaffCreated event, Emitter<StaffState> emit) async {
    try {
      final response = await dio.post('/Users', data: event.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(StaffActionSuccess('Thêm nhân viên thành công!'));
      } else {
        emit(StaffActionFailure(response.data?['message'] ?? 'Thêm nhân viên thất bại!'));
      }
    } catch (e) {
      emit(StaffActionFailure('Lỗi hệ thống: $e'));
    }
    add(StaffListRequested());
  }

  Future<void> _onUpdated(
      StaffUpdated event, Emitter<StaffState> emit) async {
    try {
      final response = await dio.put('/Users/${event.id}', data: event.data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(StaffActionSuccess('Cập nhật thành công!'));
      } else {
        emit(StaffActionFailure(response.data?['message'] ?? 'Cập nhật thất bại!'));
      }
    } catch (e) {
      emit(StaffActionFailure('Lỗi hệ thống: $e'));
    }
    add(StaffListRequested());
  }

  Future<void> _onDeleted(
      StaffDeleted event, Emitter<StaffState> emit) async {
    try {
      final response = await dio.delete('/Users/${event.id}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(StaffActionSuccess('Đã xoá nhân viên!'));
      } else {
        emit(StaffActionFailure('Xoá thất bại!'));
      }
    } catch (e) {
      emit(StaffActionFailure('Lỗi hệ thống: $e'));
    }
    add(StaffListRequested());
  }
}
