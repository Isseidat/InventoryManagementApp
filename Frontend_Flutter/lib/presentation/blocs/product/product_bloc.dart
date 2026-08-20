import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final Dio dio;

  ProductBloc({required this.dio}) : super(ProductInitial()) {
    on<ProductListRequested>(_onProductListRequested);
    on<ProductAdded>(_onProductAdded);
    on<ProductUpdated>(_onProductUpdated);
    on<ProductDeleted>(_onProductDeleted);
  }

  Future<void> _onProductListRequested(
      ProductListRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final response = await dio.get('/Products/GetAllProduct');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        emit(ProductLoaded(products: data));
      } else {
        emit(const ProductFailure('Không thể tải danh sách sản phẩm.'));
      }
    } catch (e) {
      emit(ProductFailure('Lỗi tải dữ liệu sản phẩm: $e'));
    }
  }

  Future<void> _onProductAdded(
      ProductAdded event, Emitter<ProductState> emit) async {
    try {
      final response = await dio.post('/Products/PostProduct', data: event.productData);
      if (response.data['status'] == true) {
        emit(ProductActionSuccess(response.data['message'] ?? 'Thêm sản phẩm thành công!'));
      } else {
        emit(ProductActionFailure(response.data['message'] ?? 'Thêm sản phẩm thất bại!'));
      }
    } catch (e) {
      emit(ProductActionFailure('Lỗi hệ thống: $e'));
    }
    add(ProductListRequested());
  }

  Future<void> _onProductUpdated(
      ProductUpdated event, Emitter<ProductState> emit) async {
    try {
      final response = await dio.put('/Products/${event.id}', data: event.productData);
      if (response.data['status'] == true) {
        emit(ProductActionSuccess(response.data['message'] ?? 'Cập nhật thành công!'));
      } else {
        emit(ProductActionFailure(response.data['message'] ?? 'Cập nhật thất bại!'));
      }
    } catch (e) {
      emit(ProductActionFailure('Lỗi hệ thống: $e'));
    }
    add(ProductListRequested());
  }

  Future<void> _onProductDeleted(
      ProductDeleted event, Emitter<ProductState> emit) async {
    try {
      final response = await dio.delete('/Products/${event.id}');
      if (response.data['status'] == true) {
        emit(ProductActionSuccess(response.data['message'] ?? 'Xóa thành công!'));
      } else {
        emit(ProductActionFailure(response.data['message'] ?? 'Xóa thất bại!'));
      }
    } catch (e) {
      emit(ProductActionFailure('Lỗi hệ thống: $e'));
    }
    add(ProductListRequested());
  }
}
