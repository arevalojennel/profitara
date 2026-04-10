import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../blocs/statistics/statistics_bloc.dart';
import '../blocs/statistics/statistics_event.dart';
import '../blocs/statistics/statistics_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfiTARA'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          color: isDark
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
        ),
        leading: null,
        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.refresh),
        //   //   onPressed: () =>
        //   //       context.read<StatisticsBloc>().add(UpdateStatistics()),
        //   // ),
        //   IconButton(
        //     onPressed: () {
        //       Get.to(() => const SettingsPage());
        //     },
        //     icon: const Icon(Icons.settings),
        //   )
        // ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsLoaded>(
        builder: (context, state) {
          return LiquidPullToRefresh(
            height: 60,
            showChildOpacityTransition: false,
            color: Theme.of(context).colorScheme.surface,
            // animSpeedFactor: 2,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            // springAnimationDurationInMilliseconds: 300,
            onRefresh: () async {
              context.read<StatisticsBloc>().add(UpdateStatistics());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Key metrics cards in a grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                      'Total Profit',
                      '\$${state.totalProfit.toStringAsFixed(2)}',
                      Icons.trending_up,
                      state.totalProfit >= 0 ? Colors.green : Colors.red,
                      context,
                    ),
                    _buildMetricCard(
                      'Total Revenue',
                      '\$${state.totalRevenue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.blue,
                      context,
                    ),
                    _buildMetricCard(
                      'Profit Margin',
                      '${state.overallProfitMargin.toStringAsFixed(1)}%',
                      Icons.percent,
                      state.overallProfitMargin >= 0
                          ? Colors.green
                          : Colors.red,
                      context,
                    ),
                    _buildMetricCard(
                      'Low Stock Items',
                      '${state.lowStockCount}',
                      Icons.warning,
                      state.lowStockCount > 0 ? Colors.orange : Colors.grey,
                      context,
                    ),
                    _buildMetricCard(
                      'Stock Value',
                      '\$${state.totalStockValue.toStringAsFixed(2)}',
                      Icons.inventory,
                      Colors.purple,
                      context,
                    ),
                    _buildMetricCard(
                      'Total Waste Value',
                      '\$${state.totalWasteValue.toStringAsFixed(2)}',
                      Icons.delete,
                      Colors.brown,
                      context,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Production statistics
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x33d7dfef),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Production Overview',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Total Batches Produced',
                            '${state.totalBatchesProduced}', context),
                        _buildInfoRow('Total Production Runs',
                            '${state.totalProductionRuns}', context),
                        _buildInfoRow(
                            'Average Profit per Run',
                            '\$${state.averageProfitPerRun.toStringAsFixed(2)}',
                            context),
                        const Divider(),
                        _buildInfoRow(
                          'Most Profitable Batch',
                          state.mostProfitableBatchName,
                          context,
                          valueStyle:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _buildInfoRow(
                            'Profit from Most Profitable Batch',
                            '\$${state.mostProfitableBatchProfit.toStringAsFixed(2)}',
                            context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      // elevation: 4,
      decoration: BoxDecoration(
        color: const Color(0x33d7dfef),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
