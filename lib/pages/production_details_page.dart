import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_event.dart';
import 'package:profitara/models/production_run.dart';
import 'package:intl/intl.dart';

class ProductionDetailsPage extends StatefulWidget {
  final ProductionRun run;

  const ProductionDetailsPage({super.key, required this.run});

  @override
  State<ProductionDetailsPage> createState() => _ProductionDetailsPageState();
}

class _ProductionDetailsPageState extends State<ProductionDetailsPage> {
  late int _actualSold;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _actualSold = widget.run.actualSold;
    _controller = TextEditingController(text: _actualSold.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.run.batchName),
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
                  children: [
                    _buildInfoRow('Date',
                        DateFormat.yMMMd().add_jm().format(widget.run.date)),
                    _buildInfoRow('Multiplier', '${widget.run.multiplier}'),
                    _buildInfoRow('Material Cost',
                        '\$${widget.run.materialCost.toStringAsFixed(2)}'),
                    _buildInfoRow('Current Revenue',
                        '\$${widget.run.revenue.toStringAsFixed(2)}'),
                    _buildInfoRow('Current Profit',
                        '\$${widget.run.profit.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Update Actual Sold',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual pieces sold',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
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

  void _save() {
    final newSold = int.tryParse(_controller.text);
    if (newSold != null && newSold >= 0 && newSold != widget.run.actualSold) {
      context.read<BatchBloc>().add(UpdateActualSold(widget.run.id, newSold));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }
}
