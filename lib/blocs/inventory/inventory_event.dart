import 'package:equatable/equatable.dart';
import 'package:profitara/models/stock.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadStocks extends InventoryEvent {}

class AddStock extends InventoryEvent {
  final Stock stock;
  AddStock(this.stock);
  @override
  List<Object> get props => [stock];
}

class UpdateStock extends InventoryEvent {
  final Stock stock;
  UpdateStock(this.stock);
  @override
  List<Object> get props => [stock];
}

class DeleteStock extends InventoryEvent {
  final int id;
  DeleteStock(this.id);
  @override
  List<Object> get props => [id];
}

class AddWaste extends InventoryEvent {
  final int stockId;
  final double amount;
  final String unit;
  AddWaste(this.stockId, this.amount, this.unit);
  @override
  List<Object> get props => [stockId, amount, unit];
}

class AddStockQuantity extends InventoryEvent {
  // New event
  final int stockId;
  final double amount;
  final String unit;
  AddStockQuantity(this.stockId, this.amount, this.unit);
  @override
  List<Object> get props => [stockId, amount, unit];
}

class LoadCategories extends InventoryEvent {}

class AddCategory extends InventoryEvent {
  final String name;
  AddCategory(this.name);
  @override
  List<Object> get props => [name];
}
