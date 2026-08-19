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
