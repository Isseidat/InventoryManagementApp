import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Dio dio;

  TransactionBloc({required this.dio}) : super(TransactionInitial()) {
    on<TransactionListRequested>(_onListRequested);
    on<TransactionCreatePurchaseOrder>(_onCreatePO);
    on<TransactionCreateSalesOrder>(_onCreateSO);
    on<TransactionReceivePO>(_onReceivePO);
    on<TransactionApproveSO>(_onApproveSO);
    on<TransactionShipSO>(_onShipSO);
  }

  Future<void> _onListRequested(
      TransactionListRequested event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final poResponse = await dio.get('/PurchaseOrders');
      final soResponse = await dio.get('/SalesOrders');
      final List<dynamic> pos = poResponse.statusCode == 200 ? poResponse.data : [];
      final List<dynamic> sos = soResponse.statusCode == 200 ? soResponse.data : [];
      emit(TransactionLoaded(purchaseOrders: pos, salesOrders: sos));
    } catch (e) {
      emit(TransactionFailure('Lỗi tải dữ liệu giao dịch: $e'));
    }
  }

  Future<void> _onCreatePO(
      TransactionCreatePurchaseOrder event, Emitter<TransactionState> emit) async {
    try {
      final response = await dio.post('/PurchaseOrders', data: event.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(TransactionActionSuccess('Tạo Phiếu Nhập thành công!'));
      } else {
        emit(TransactionActionFailure('Tạo Phiếu Nhập thất bại!'));
      }
    } catch (e) {
      emit(TransactionActionFailure('Lỗi hệ thống: $e'));
    }
    add(TransactionListRequested());
  }

  Future<void> _onCreateSO(
      TransactionCreateSalesOrder event, Emitter<TransactionState> emit) async {
    try {
      final response = await dio.post('/SalesOrders', data: event.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(TransactionActionSuccess('Tạo Phiếu Xuất thành công!'));
      } else {
        emit(TransactionActionFailure('Tạo Phiếu Xuất thất bại!'));
      }
    } catch (e) {
      emit(TransactionActionFailure('Lỗi hệ thống: $e'));
    }
    add(TransactionListRequested());
  }

  Future<void> _onReceivePO(
      TransactionReceivePO event, Emitter<TransactionState> emit) async {
    try {
      final response = await dio.put('/PurchaseOrders/${event.orderId}/Receive');
      if (response.statusCode == 200) {
        emit(TransactionActionSuccess('Nhận hàng thành công! Kho đã được cập nhật.'));
      } else {
        emit(TransactionActionFailure(response.data?['message'] ?? 'Nhận hàng thất bại!'));
      }
    } catch (e) {
      emit(TransactionActionFailure('Lỗi hệ thống: $e'));
    }
    add(TransactionListRequested());
  }

  Future<void> _onApproveSO(
      TransactionApproveSO event, Emitter<TransactionState> emit) async {
    try {
      final response = await dio.put('/SalesOrders/${event.orderId}/Approve');
      if (response.statusCode == 200) {
        emit(TransactionActionSuccess('Duyệt đơn hàng thành công!'));
      } else {
        emit(TransactionActionFailure(response.data?['message'] ?? 'Duyệt đơn thất bại!'));
      }
    } catch (e) {
      emit(TransactionActionFailure('Lỗi hệ thống: $e'));
    }
    add(TransactionListRequested());
  }

  Future<void> _onShipSO(
      TransactionShipSO event, Emitter<TransactionState> emit) async {
    try {
      final response = await dio.put('/SalesOrders/${event.orderId}/Ship');
      if (response.statusCode == 200) {
        emit(TransactionActionSuccess('Xuất kho thành công! Hàng đã giao.'));
      } else {
        emit(TransactionActionFailure(response.data?['message'] ?? 'Xuất kho thất bại!'));
      }
    } catch (e) {
      emit(TransactionActionFailure('Lỗi hệ thống: $e'));
    }
    add(TransactionListRequested());
  }
}
