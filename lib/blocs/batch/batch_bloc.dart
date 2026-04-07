import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/batch/batch_event.dart';
import 'package:profitara/blocs/batch/batch_state.dart';
import 'package:profitara/models/batch.dart';
import 'package:profitara/repositories/batch_repository.dart';
import 'package:profitara/repositories/stock_repository.dart';
import 'package:profitara/utils/converters.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  final BatchRepository batchRepository;
  final StockRepository stockRepository;

  BatchBloc(this.batchRepository, this.stockRepository)
      : super(BatchLoading()) {
    on<LoadBatches>(_onLoadBatches);
    on<AddBatch>(_onAddBatch);
    on<StartProduction>(_onStartProduction);
    on<LoadProductionRuns>(_onLoadProductionRuns);
    on<UpdateActualSold>(_onUpdateActualSold);
  }

  Future<void> _onLoadBatches(
      LoadBatches event, Emitter<BatchState> emit) async {
    try {
      final List<Batch> batches = await batchRepository.getAllBatches();
      emit(BatchesLoaded(batches));
    } catch (e) {
      emit(BatchError(e.toString()));
    }
  }

  Future<void> _onAddBatch(AddBatch event, Emitter<BatchState> emit) async {
    try {
      await batchRepository.insertBatch(event.batch);
      add(LoadBatches());
    } catch (e) {
      emit(BatchError(e.toString()));
    }
  }

  Future<void> _onStartProduction(
      StartProduction event, Emitter<BatchState> emit) async {
    try {
      final batches = await batchRepository.getAllBatches();
      final batch = batches.firstWhere((b) => b.id == event.batchId);
      final stocks = await stockRepository.getAllStocks();

      // Check and deduct materials
      for (var material in batch.materials) {
        final stock = stocks.firstWhere((s) => s.id == material.stockId);
        double requiredBase = UnitConverter.convertToBase(
          material.quantity * event.multiplier,
          material.unitName,
          stock.baseUnit,
          customPieces: stock.unitPieces,
        );
        if (stock.quantity < requiredBase) {
          // Show error and reload batches to avoid disappearing list
          add(LoadBatches());
          emit(BatchError('Insufficient stock for ${stock.name}'));
          return;
        }
        stock.quantity -= requiredBase;
        await stockRepository.updateStock(stock);
      }

      // Calculate material cost
      double totalMaterialCost = 0;
      for (var material in batch.materials) {
        final stock = stocks.firstWhere((s) => s.id == material.stockId);
        double baseQty = UnitConverter.convertToBase(
          material.quantity,
          material.unitName,
          stock.baseUnit,
          customPieces: stock.unitPieces,
        );
        totalMaterialCost += baseQty * stock.costPerBaseUnit;
      }
      totalMaterialCost *= event.multiplier;

      double revenue =
          batch.recommendedSellingPrice * batch.piecesYield * event.multiplier;
      double profit = revenue - totalMaterialCost;

      // Update produced count
      batch.producedCount += event.multiplier;
      await batchRepository.updateBatch(batch);
      await batchRepository.addProductionRun(
        batch.id,
        event.multiplier,
        profit,
        revenue,
        totalMaterialCost,
        batch.piecesYield * event.multiplier,
      );

      // Reload batches and show success
      add(LoadBatches());
      // Optionally show success message via listener
    } catch (e, stack) {
      print('Production error: $e\n$stack');
      add(LoadBatches()); // Still reload to show the original list
      emit(BatchError('Production failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductionRuns(
      LoadProductionRuns event, Emitter<BatchState> emit) async {
    try {
      final runs = await batchRepository.getAllProductionRuns();
      emit(ProductionRunsLoaded(runs));
    } catch (e) {
      emit(BatchError(e.toString()));
    }
  }

  Future<void> _onUpdateActualSold(
      UpdateActualSold event, Emitter<BatchState> emit) async {
    try {
      final runs = await batchRepository.getAllProductionRuns();
      final run = runs.firstWhere((r) => r.id == event.runId);
      final batch = await batchRepository.getBatch(run.batchId);

      final newRevenue = batch.recommendedSellingPrice * event.actualSold;
      final newProfit = newRevenue - run.materialCost;

      run.actualSold = event.actualSold;
      run.revenue = newRevenue;
      run.profit = newProfit;

      await batchRepository.updateProductionRun(run);
      add(LoadProductionRuns()); // Reload list
    } catch (e) {
      emit(BatchError(e.toString()));
    }
  }
}
