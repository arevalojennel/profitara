import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_event.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/models/batch.dart';
import 'package:profitara/pages/main_page.dart';
import 'package:profitara/utils/unit_conversions.dart';

class BatchDetailsPage extends StatefulWidget {
  final Batch batch;

  const BatchDetailsPage({super.key, required this.batch});

  @override
  State<BatchDetailsPage> createState() => _BatchDetailsPageState();
}

class _BatchDetailsPageState extends State<BatchDetailsPage> {
  final _multiplierController = TextEditingController(text: '1');
  double _multiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _multiplierController.addListener(_updateMultiplier);
  }

  @override
  void dispose() {
    _multiplierController.removeListener(_updateMultiplier);
    _multiplierController.dispose();
    super.dispose();
  }

  void _updateMultiplier() {
    final value = double.tryParse(_multiplierController.text) ?? 1.0;
    setState(() {
      _multiplier = value < 1 ? 1 : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = context.watch<InventoryBloc>().state;
    if (inventoryState is! InventoryLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Batch Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final stocks = inventoryState.stocks;

    // Calculate costs per run
    double materialCostPerRun = 0;
    final materialDetails = <Map<String, dynamic>>[];

    for (var material in widget.batch.materials) {
      try {
        final stock = stocks.firstWhere((s) => s.id == material.stockId);
        double baseQty = UnitConversions.convert(
          value: material.quantity,
          fromUnit: material.unitName,
          toUnit: stock.baseUnit,
        );
        double cost = baseQty * stock.costPerBaseUnit;
        materialCostPerRun += cost;
        materialDetails.add({
          'name': stock.name,
          'quantity': material.quantity,
          'unit': material.unitName,
          'cost': cost,
        });
      } catch (e) {
        materialDetails.add({
          'name': 'Unknown Stock',
          'quantity': material.quantity,
          'unit': material.unitName,
          'cost': 0.0,
        });
      }
    }

    double revenuePerRun =
        widget.batch.recommendedSellingPrice * widget.batch.piecesYield;
    double profitPerRun = revenuePerRun - materialCostPerRun;

    // Totals with multiplier
    double totalMaterialCost = materialCostPerRun * _multiplier;
    double totalRevenue = revenuePerRun * _multiplier;
    double totalProfit = profitPerRun * _multiplier;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit batch page (if needed)
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batch Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildInfoRow('Yield', '${widget.batch.piecesYield} pieces'),
                  _buildInfoRow(
                      'Profit Margin', '${widget.batch.profitMargin}%'),
                  _buildInfoRow('Selling Price per Piece',
                      '\$${widget.batch.recommendedSellingPrice.toStringAsFixed(2)}'),
                  _buildInfoRow(
                      'Produced Count', '${widget.batch.producedCount}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Materials',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...materialDetails.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(m['name']),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${m['quantity']} ${m['unit']}',
                                  textAlign: TextAlign.right),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${m['cost'].toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Material Cost (per run)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${materialCostPerRun.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Production Multiplier',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _multiplierController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Multiplier',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          double current =
                              double.parse(_multiplierController.text);
                          _multiplierController.text = (current + 1).toString();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          double current =
                              double.parse(_multiplierController.text);
                          if (current > 1) {
                            _multiplierController.text =
                                (current - 1).toString();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Material Cost',
                      '\$${totalMaterialCost.toStringAsFixed(2)}'),
                  _buildInfoRow(
                      'Revenue', '\$${totalRevenue.toStringAsFixed(2)}'),
                  _buildInfoRow(
                    'Profit',
                    '\$${totalProfit.toStringAsFixed(2)}',
                    color: totalProfit >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        int mult = _multiplier.toInt();
                        if (mult > 0) {
                          context
                              .read<BatchBloc>()
                              .add(StartProduction(widget.batch.id, mult));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Production started!')),
                          );
                          Get.to(() => const MainPage(
                                selectedIndex: 3,
                              ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Start Production',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
