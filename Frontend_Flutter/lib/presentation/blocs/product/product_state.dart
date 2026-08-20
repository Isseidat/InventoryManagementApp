import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<dynamic> products;

  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductActionSuccess extends ProductState {
  final String message;
  const ProductActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductActionFailure extends ProductState {
  final String message;
  const ProductActionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
