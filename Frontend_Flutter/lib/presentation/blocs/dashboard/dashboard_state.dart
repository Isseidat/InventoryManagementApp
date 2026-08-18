import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalProducts;
  final int activeUsers;
  final int pendingSales;
  final int pendingPurchases;
  final int todayStockIn;
  final int todayStockOut;
  final List<dynamic> recentActivities;

  DashboardLoaded({
    required this.totalProducts,
    required this.activeUsers,
    required this.pendingSales,
    required this.pendingPurchases,
    required this.todayStockIn,
    required this.todayStockOut,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
        totalProducts,
        activeUsers,
        pendingSales,
        pendingPurchases,
        todayStockIn,
        todayStockOut,
        recentActivities,
      ];
}

class DashboardFailure extends DashboardState {
  final String message;
  DashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}
