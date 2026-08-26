import 'package:flutter/foundation.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<dynamic> purchaseOrders;
  final List<dynamic> salesOrders;
  TransactionLoaded({required this.purchaseOrders, required this.salesOrders});
}

class TransactionFailure extends TransactionState {
  final String error;
  TransactionFailure(this.error);
}

class TransactionActionSuccess extends TransactionState {
  final String message;
  TransactionActionSuccess(this.message);
}

class TransactionActionFailure extends TransactionState {
  final String error;
  TransactionActionFailure(this.error);
}
