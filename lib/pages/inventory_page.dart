// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_event.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/pages/add_stock_page.dart';
import 'package:profitara/pages/widgets/stock_tile.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool showLowStock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryBloc>().add(LoadStocks()),
          ),
        ],
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is InventoryLoaded) {
            final stocks = showLowStock
                ? state.stocks.where((s) => s.isLowStock).toList()
                : state.stocks;
            return Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Low Stock Only'),
                  value: showLowStock,
                  onChanged: (val) => setState(() => showLowStock = val),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: stocks.length,
                    itemBuilder: (ctx, i) => StockTile(stock: stocks[i]),
                  ),
                ),
              ],
            );
          } else if (state is InventoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddStockPage()),
        ),
      ),
    );
  }
}
