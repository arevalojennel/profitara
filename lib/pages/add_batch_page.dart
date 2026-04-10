import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_event.dart';
import 'package:profitara/blocs/batch/batch_state.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/models/batch.dart';
import 'package:profitara/models/stock.dart';
import 'package:profitara/pages/widgets/material_selector.dart';
import 'package:profitara/utils/unit_conversions.dart';

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yieldController = TextEditingController();
  final _marginController = TextEditingController();

  List<BatchMaterial> materials = [];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<BatchBloc, BatchState>(
      listener: (context, state) {
        if (state is BatchError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } else if (state is BatchesLoaded && _isSaving) {
          // Success - new batch added and list reloaded
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batch saved successfully!')),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Batch')),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is! InventoryLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final stocks = state.stocks;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Batch Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('Materials',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        MaterialSelector(
                          stocks: stocks,
                          onAdd: _addMaterial,
                        ),
                        ...materials.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var material = entry.value;
                          Stock stock = stocks
                              .firstWhere((s) => s.id == material.stockId);
                          return ListTile(
                            title: Text(stock.name),
                            subtitle: Text(
                                '${material.quantity} ${material.unitName}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  materials.removeAt(idx);
                                });
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _yieldController,
                          decoration: const InputDecoration(
                              labelText: 'Yield (pieces)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _marginController,
                          decoration: const InputDecoration(
                              labelText: 'Profit Margin (%)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        if (_yieldController.text.isNotEmpty &&
                            _marginController.text.isNotEmpty &&
                            materials.isNotEmpty)
                          FutureBuilder<double>(
                            future: _calculateTotalCost(stocks),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();
                              double totalCost = snapshot.data!;
                              double yieldValue =
                                  double.parse(_yieldController.text);
                              double margin =
                                  double.parse(_marginController.text) / 100;
                              double pricePerPiece =
                                  (totalCost / yieldValue) * (1 + margin);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Recommended Selling Price: \$${pricePerPiece.toStringAsFixed(2)} per piece',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _calculateTotalCost(stocks);
                                  setState(
                                      () {}); // Force rebuild to refresh the FutureBuilder
                                },
                                style: ElevatedButton.styleFrom(
                                  // minimumSize: const Size(double.infinity, 50),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator())
                                    : Text(
                                        'Calculate Cost',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveBatch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator())
                                    : Text(
                                        'Save Batch',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: isDark
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSaving)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addMaterial(Stock stock, double qty, String unit) {
    setState(() {
      materials
          .add(BatchMaterial(stockId: stock.id, quantity: qty, unitName: unit));
    });
  }

  Future<void> _saveBatch() async {
    if (_formKey.currentState!.validate() && materials.isNotEmpty) {
      setState(() => _isSaving = true);
      final stocks =
          (context.read<InventoryBloc>().state as InventoryLoaded).stocks;
      try {
        double totalCost = await _calculateTotalCost(stocks);
        int piecesYield = int.parse(_yieldController.text);
        double margin = double.parse(_marginController.text);
        double price = (totalCost / piecesYield) * (1 + margin / 100);
        final batch = Batch(
          id: 0,
          name: _nameController.text,
          created: DateTime.now(),
          materials: materials,
          piecesYield: piecesYield,
          profitMargin: margin,
          recommendedSellingPrice: price,
        );
        // print('Saving batch: ${batch.name}');
        if (!mounted) return;
        context.read<BatchBloc>().add(AddBatch(batch));
        // Success/failure handled by BlocListener
      } catch (e, stack) {
        print('Error in _saveBatch: $e');
        print(stack);
        setState(() => _isSaving = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one material'),
            backgroundColor: Colors.orange),
      );
    }
  }

  Future<double> _calculateTotalCost(List<Stock> stocks) async {
    double total = 0;
    for (var material in materials) {
      Stock stock = stocks.firstWhere((s) => s.id == material.stockId);
      double baseQty = UnitConversions.convert(
        value: material.quantity,
        fromUnit: material.unitName,
        toUnit: stock.baseUnit,
        customPieces: stock.unitPieces, // <-- add this
      );
      total += baseQty * stock.costPerBaseUnit;
    }
    return total;
  }
}
