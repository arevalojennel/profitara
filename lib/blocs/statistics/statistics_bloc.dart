import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/statistics/statistics_event.dart';
import 'package:profitara/blocs/statistics/statistics_state.dart';
import 'package:profitara/repositories/batch_repository.dart';
import 'package:profitara/repositories/stock_repository.dart';
import 'package:profitara/repositories/waste_repository.dart';
import 'package:profitara/database/database_helper.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsLoaded> {
  final StockRepository stockRepository;
  final BatchRepository batchRepository;
  final WasteRepository wasteRepository;

  StatisticsBloc(
      this.stockRepository, this.batchRepository, this.wasteRepository)
      : super(const StatisticsLoaded(
          totalProfit: 0,
          totalRevenue: 0,
          lowStockCount: 0,
          totalStockValue: 0,
          overallProfitMargin: 0,
          totalBatchesProduced: 0,
          totalProductionRuns: 0,
          averageProfitPerRun: 0,
          mostProfitableBatchName: '',
          mostProfitableBatchProfit: 0,
          totalWasteValue: 0,
        )) {
    on<UpdateStatistics>(_onUpdateStatistics);
  }

  Future<void> _onUpdateStatistics(
      UpdateStatistics event, Emitter<StatisticsLoaded> emit) async {
    final stocks = await stockRepository.getAllStocks();
    final lowStockCount = stocks.where((s) => s.isLowStock).length;
    final totalStockValue = stocks.fold(0.0, (sum, s) => sum + s.stockValue);

    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> runs = await db.query('production_runs');
    double totalProfit = 0;
    double totalRevenue = 0;
    for (var run in runs) {
      totalProfit += run['profit'];
      totalRevenue += run['revenue'];
    }

    final totalBatchesProduced =
        await batchRepository.getTotalBatchesProduced();
    final totalProductionRuns = await batchRepository.getTotalProductionRuns();
    final overallProfitMargin =
        totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0;
    final averageProfitPerRun =
        totalProductionRuns > 0 ? totalProfit / totalProductionRuns : 0;
    final mostProfitable = await batchRepository.getMostProfitableBatch();
    final totalWasteValue = await wasteRepository.getTotalWasteValue();

    emit(StatisticsLoaded(
      totalProfit: totalProfit,
      totalRevenue: totalRevenue,
      lowStockCount: lowStockCount,
      totalStockValue: totalStockValue,
      overallProfitMargin: overallProfitMargin,
      totalBatchesProduced: totalBatchesProduced,
      totalProductionRuns: totalProductionRuns,
      averageProfitPerRun: averageProfitPerRun,
      mostProfitableBatchName: mostProfitable?['name'] ?? 'None',
      mostProfitableBatchProfit: mostProfitable?['profit'] ?? 0.0,
      totalWasteValue: totalWasteValue,
    ));
  }
}
