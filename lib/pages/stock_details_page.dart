import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_event.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/models/stock.dart';
import 'package:profitara/pages/main_page.dart';
import 'package:profitara/pages/widgets/unit_dropdown.dart';

class StockDetailsPage extends StatelessWidget {
  final int stockId;

  const StockDetailsPage({super.key, required this.stockId});

  void _confirmDelete(BuildContext context, Stock stock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stock'),
        content: Text(
            'Are you sure you want to delete "${stock.name}"? This will also remove all related waste records and batch materials.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteStock(stock.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
              Get.to(() => const MainPage(selectedIndex: 1));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final stock = state.stocks.firstWhere(
            (s) => s.id == stockId,
            // orElse: () => throw Exception('Stock not found'),
          );

          // Get formatted values
          final (qtyDisplay, qtyUnit) = stock.getDisplayQuantity();
          final (totalAddedDisplay, totalAddedUnit) =
              stock.getDisplayForValue(stock.totalAddedQuantity);
          final (minDisplay, minUnit) =
              stock.getDisplayForValue(stock.minStockLevel);
          final (wasteQtyDisplay, wasteQtyUnit) =
              stock.getDisplayForValue(stock.wasteQuantity);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Stock Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, stock),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current quantity
                          _buildInfoRow(
                            'Current Quantity',
                            '${_formatNumber(qtyDisplay)} $qtyUnit${qtyDisplay != 1 ? 's' : ''}',
                          ),

                          // Total quantity ever added
                          _buildInfoRow(
                            'Total Quantity Added',
                            '${_formatNumber(totalAddedDisplay)} $totalAddedUnit${totalAddedDisplay != 1 ? 's' : ''}',
                          ),

                          // Minimum stock
                          _buildInfoRow(
                            'Minimum Stock',
                            '${_formatNumber(minDisplay)} $minUnit${minDisplay != 1 ? 's' : ''}',
                          ),

                          // Cost per base unit
                          _buildInfoRow(
                            'Cost per ${stock.baseUnit}',
                            '\$${stock.costPerBaseUnit.toStringAsFixed(2)}',
                          ),

                          // Total value of current stock
                          _buildInfoRow(
                            'Total Stock Value',
                            '\$${stock.stockValue.toStringAsFixed(2)}',
                          ),

                          // Waste quantity (formatted)
                          _buildInfoRow(
                            'Total Waste Quantity',
                            '${_formatNumber(wasteQtyDisplay)} $wasteQtyUnit${wasteQtyDisplay != 1 ? 's' : ''}',
                          ),

                          // Waste value (currency)
                          _buildInfoRow(
                            'Total Waste Value',
                            '\$${stock.wasteValue.toStringAsFixed(2)}',
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'Available Units: ${stock.availableUnits.join(', ')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showAddDialog(context, stock),
                          child: const Text('Add Stock'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showWasteDialog(context, stock),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Add Waste'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Helper to format numbers: if integer, show without decimals
  String _formatNumber(double value) {
    return value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  void _showAddDialog(BuildContext context, Stock stock) {
    final amountController = TextEditingController();
    String? selectedUnit = stock.baseUnit;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Add Stock to ${stock.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              UnitDropdown(
                units: stock.availableUnits,
                selectedUnit: selectedUnit,
                onChanged: (unit) => setState(() => selectedUnit = unit),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0 && selectedUnit != null) {
                  context
                      .read<InventoryBloc>()
                      .add(AddStockQuantity(stock.id, amount, selectedUnit!));
                  Navigator.pop(ctx);
                  context.read<InventoryBloc>().add(LoadStocks());
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWasteDialog(BuildContext context, Stock stock) {
    final amountController = TextEditingController();
    String? selectedUnit = stock.baseUnit;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Add Waste for ${stock.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              UnitDropdown(
                units: stock.availableUnits,
                selectedUnit: selectedUnit,
                onChanged: (unit) => setState(() => selectedUnit = unit),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0 && selectedUnit != null) {
                  context
                      .read<InventoryBloc>()
                      .add(AddWaste(stock.id, amount, selectedUnit!));
                  Navigator.pop(ctx);
                  context.read<InventoryBloc>().add(LoadStocks());
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
