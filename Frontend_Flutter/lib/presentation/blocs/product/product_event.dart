import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductListRequested extends ProductEvent {}

class ProductAdded extends ProductEvent {
  final Map<String, dynamic> productData;
  const ProductAdded(this.productData);
  @override
  List<Object?> get props => [productData];
}

class ProductUpdated extends ProductEvent {
  final int id;
  final Map<String, dynamic> productData;
  const ProductUpdated(this.id, this.productData);
  @override
  List<Object?> get props => [id, productData];
}

class ProductDeleted extends ProductEvent {
  final int id;
  const ProductDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
