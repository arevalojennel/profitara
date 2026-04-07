import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_event.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/models/waste.dart';
import 'package:profitara/repositories/stock_repository.dart';
import 'package:profitara/repositories/waste_repository.dart';
import 'package:profitara/utils/converters.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final StockRepository stockRepository;
  final WasteRepository wasteRepository;

  InventoryBloc(this.stockRepository, this.wasteRepository)
      : super(InventoryLoading()) {
    on<LoadStocks>(_onLoadStocks);
    on<AddStock>(_onAddStock);
    on<UpdateStock>(_onUpdateStock);
    on<DeleteStock>(_onDeleteStock);
    on<AddWaste>(_onAddWaste);
    on<AddStockQuantity>(_onAddStockQuantity); // New handler
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
  }

  Future<void> _onLoadStocks(
      LoadStocks event, Emitter<InventoryState> emit) async {
    try {
      final stocks = await stockRepository.getAllStocks();
      final categories = await stockRepository.getCategories();
      emit(InventoryLoaded(stocks, categories));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddStock(AddStock event, Emitter<InventoryState> emit) async {
    try {
      event.stock.totalAddedQuantity = event.stock.quantity;
      await stockRepository.insertStock(event.stock);
      add(LoadStocks());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateStock(
      UpdateStock event, Emitter<InventoryState> emit) async {
    try {
      await stockRepository.updateStock(event.stock);
      add(LoadStocks());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteStock(
      DeleteStock event, Emitter<InventoryState> emit) async {
    try {
      await stockRepository.deleteStock(event.id);
      add(LoadStocks());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddWaste(AddWaste event, Emitter<InventoryState> emit) async {
    try {
      final stocks = await stockRepository.getAllStocks();
      final stock = stocks.firstWhere((s) => s.id == event.stockId);
      double baseAmount = UnitConverter.convertToBase(
        event.amount,
        event.unit,
        stock.baseUnit,
        customPieces: stock.unitPieces,
      );
      if (stock.quantity < baseAmount) {
        emit(InventoryError('Insufficient stock'));
        return;
      }
      stock.quantity -= baseAmount;
      stock.wasteQuantity += baseAmount;
      stock.wasteValue += baseAmount * stock.costPerBaseUnit;
      await stockRepository.updateStock(stock);
      await wasteRepository.addWaste(WasteEntry(
        id: 0,
        stockId: event.stockId,
        amount: baseAmount,
        date: DateTime.now(),
      ));
      add(LoadStocks());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // New handler for adding stock quantity
  Future<void> _onAddStockQuantity(
      AddStockQuantity event, Emitter<InventoryState> emit) async {
    try {
      final stocks = await stockRepository.getAllStocks();
      final stock = stocks.firstWhere((s) => s.id == event.stockId);
      // 🆕 Pass customPieces to the converter
      double baseAmount = UnitConverter.convertToBase(
        event.amount,
        event.unit,
        stock.baseUnit,
        customPieces: stock.unitPieces, // 👈 Add this
      );
      stock.quantity += baseAmount;
      // If you have totalAddedQuantity, update it too
      stock.totalAddedQuantity += baseAmount;
      await stockRepository.updateStock(stock);
      add(LoadStocks());
    } catch (e) {
      // Instead of emitting an error that blocks the UI, we can:
      // 1. Re-emit the previous loaded state (if we have it)
      // 2. Or, better, use a listener to show a snackbar.
      // For now, let's keep the error but ensure the UI handles it.
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<InventoryState> emit) async {
    try {
      final categories = await stockRepository.getCategories();
      if (state is InventoryLoaded) {
        emit(InventoryLoaded((state as InventoryLoaded).stocks, categories));
      } else {
        emit(InventoryLoaded(const [], categories));
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<InventoryState> emit) async {
    try {
      await stockRepository.addCategory(event.name);
      add(LoadCategories());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
