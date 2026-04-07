import 'package:equatable/equatable.dart';
import 'package:profitara/models/category.dart';
import 'package:profitara/models/stock.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Stock> stocks;
  final List<Category> categories;
  InventoryLoaded(this.stocks, this.categories);
  @override
  List<Object> get props => [stocks, categories];
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
  @override
  List<Object> get props => [message];
}
