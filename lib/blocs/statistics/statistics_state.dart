import 'package:equatable/equatable.dart';

class StatisticsLoaded extends Equatable {
  final double totalProfit;
  final double totalRevenue;
  final int lowStockCount;
  final double totalStockValue;
  final num overallProfitMargin;
  final int totalBatchesProduced;
  final int totalProductionRuns;
  final num averageProfitPerRun;
  final String mostProfitableBatchName;
  final double mostProfitableBatchProfit;
  final double totalWasteValue;

  const StatisticsLoaded({
    required this.totalProfit,
    required this.totalRevenue,
    required this.lowStockCount,
    required this.totalStockValue,
    required this.overallProfitMargin,
    required this.totalBatchesProduced,
    required this.totalProductionRuns,
    required this.averageProfitPerRun,
    required this.mostProfitableBatchName,
    required this.mostProfitableBatchProfit,
    required this.totalWasteValue,
  });

  @override
  List<Object> get props => [
        totalProfit,
        totalRevenue,
        lowStockCount,
        totalStockValue,
        overallProfitMargin,
        totalBatchesProduced,
        totalProductionRuns,
        averageProfitPerRun,
        mostProfitableBatchName,
        mostProfitableBatchProfit,
        totalWasteValue,
      ];
}
