import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_state.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/statistics/statistics_bloc.dart';
import 'package:profitara/blocs/statistics/statistics_event.dart';
import 'package:profitara/pages/main_page.dart';
import 'package:profitara/providers/theme_provider.dart';
import 'package:profitara/repositories/batch_repository.dart';
import 'package:profitara/repositories/stock_repository.dart';
import 'package:profitara/repositories/waste_repository.dart';
import 'package:profitara/theme/app_theme.dart';

import 'blocs/batch/batch_event.dart';
import 'blocs/inventory/inventory_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final stockRepository = StockRepository();
  final batchRepository = BatchRepository();
  final wasteRepository = WasteRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => InventoryBloc(stockRepository, wasteRepository)
              ..add(LoadStocks()),
          ),
          BlocProvider(
            create: (_) =>
                BatchBloc(batchRepository, stockRepository)..add(LoadBatches()),
          ),
          BlocProvider(
            create: (_) => StatisticsBloc(
                stockRepository, batchRepository, wasteRepository)
              ..add(UpdateStatistics()),
          ),
        ],
        child: BlocListener<BatchBloc, BatchState>(
          listenWhen: (previous, current) => true,
          listener: (context, state) {
            context.read<StatisticsBloc>().add(UpdateStatistics());
          },
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return GetMaterialApp(
                title: 'Profitara',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeModeValue,
                home: const MainPage(),
              );
            },
          ),
        ),
      ),
    );
  }
}
