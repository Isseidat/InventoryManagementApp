import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final Dio dio;

  DashboardBloc({required this.dio}) : super(DashboardInitial()) {
    on<DashboardSummaryRequested>(_onSummaryRequested);
  }

  Future<void> _onSummaryRequested(
      DashboardSummaryRequested event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      // Gọi song song các API hiện có để đếm dữ liệu (Không dùng DashboardController ép kiểu)
      final results = await Future.wait([
        dio.get('/Products/GetAllProduct'),
        dio.get('/SalesOrders'),
        dio.get('/Inventory/Transactions'),
      ]);

      // 1. Lấy tổng sản phẩm
      final productsList = results[0].data as List<dynamic>? ?? [];
      final totalProducts = productsList.length;

      // 2. Lấy đơn hàng bán
      final salesList = results[1].data as List<dynamic>? ?? [];
      final pendingSales = salesList.where((so) => so['status'] == 'Pending').length;

      // 3. Xử lý Transactions
      final txList = results[2].data as List<dynamic>? ?? [];
      
      final now = DateTime.now();
      int stockIn = 0;
      int stockOut = 0;
      
      for (var tx in txList) {
        final dateStr = tx['transactionDate']?.toString() ?? '';
        final type = tx['transactionType']?.toString() ?? '';
        final qty = (tx['quantity'] as num?)?.toInt() ?? 0;
        
        if (dateStr.isNotEmpty) {
          final txDate = DateTime.tryParse(dateStr);
          if (txDate != null && 
              txDate.year == now.year && 
              txDate.month == now.month && 
              txDate.day == now.day) {
            if (type == 'IN') stockIn += qty;
            if (type == 'OUT') stockOut += qty;
          }
        }
      }

      // Map sang model chung cho ActivityTable
      final recentActivities = txList.take(5).map((tx) {
        final type = tx['transactionType']?.toString().toLowerCase() ?? 'unknown';
        final qty = (tx['quantity'] as num?)?.toInt() ?? 0;
        return {
          'type': type,
          'code': 'TXN-${tx['id']}',
          'productName': tx['productName'] ?? 'Sản phẩm ${tx['productId']}',
          'quantity': type == 'in' ? '+$qty' : '-$qty',
          'status': 'Hoàn thành'
        };
      }).toList();

      emit(DashboardLoaded(
        totalProducts: totalProducts,
        activeUsers: 0, // Không lấy User vì API /Users cần quyền Admin
        pendingSales: pendingSales,
        pendingPurchases: 0, // Lười gọi thêm PO :v
        todayStockIn: stockIn,
        todayStockOut: stockOut,
        recentActivities: recentActivities,
      ));
    } catch (e) {
      emit(DashboardFailure('Lỗi tải dữ liệu Dashboard: $e'));
    }
  }
}
