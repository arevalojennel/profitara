import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/statistics/statistics_bloc.dart';
import 'package:profitara/blocs/statistics/statistics_event.dart';
import 'package:profitara/pages/batch_page.dart';
import 'package:profitara/pages/inventory_page.dart';
import 'package:profitara/pages/production_list_page.dart';
import 'package:profitara/pages/settings_page.dart';
import 'package:profitara/pages/statistics_page.dart';
import 'package:profitara/theme/app_colors.dart';

import '../blocs/batch/batch_event.dart';
import '../blocs/inventory/inventory_bloc.dart';
import '../blocs/inventory/inventory_event.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.selectedIndex = 2});
  final int selectedIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int? _selectedIndex;
  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
    super.initState();
  }

  final List<Widget> _pages = [
    const ProductionListPage(),
    const InventoryPage(),
    const StatisticsPage(),
    const BatchPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex ?? 2],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex ?? 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            context.read<StatisticsBloc>().add(UpdateStatistics());
          }
          if (index == 1) {
            context.read<InventoryBloc>().add(LoadStocks());
          }
          if (index == 3) {
            context.read<BatchBloc>().add(LoadBatches());
          }
          if (index == 0) {
            context.read<BatchBloc>().add(LoadProductionRuns());
          }
        },
        items: [
          bottomNavigationItemIcon(Icons.work_history),
          bottomNavigationItemIcon(Icons.inventory),
          bottomNavigationItemIcon(Icons.bar_chart),
          bottomNavigationItemIcon(Icons.production_quantity_limits),
          bottomNavigationItemIcon(Icons.settings),
        ],
      ),
    );
  }

  Widget bottomNavigationItemIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        size: 25,
        color: AppColors.onPrimaryLight,
      ),
    );
  }
}
