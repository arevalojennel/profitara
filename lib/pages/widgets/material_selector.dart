import 'package:flutter/material.dart';
import 'package:profitara/models/stock.dart';
import 'package:profitara/pages/widgets/unit_dropdown.dart';

class MaterialSelector extends StatefulWidget {
  final List<Stock> stocks;
  final Function(Stock stock, double qty, String unit) onAdd;

  const MaterialSelector(
      {super.key, required this.stocks, required this.onAdd});

  @override
  State<MaterialSelector> createState() => _MaterialSelectorState();
}

class _MaterialSelectorState extends State<MaterialSelector> {
  Stock? _selectedStock;
  String? _selectedUnit;
  final _qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Stock>(
          initialValue: _selectedStock,
          items: widget.stocks
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (s) {
            setState(() {
              _selectedStock = s;
              _selectedUnit = s?.baseUnit;
            });
          },
          decoration: const InputDecoration(labelText: 'Select Material'),
        ),
        const SizedBox(height: 16),
        if (_selectedStock != null) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
              ),
              const SizedBox(width: 8),
              UnitDropdown(
                units: _selectedStock!.availableUnits,
                selectedUnit: _selectedUnit,
                onChanged: (u) => setState(() => _selectedUnit = u),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(_qtyController.text) ?? 0;
              if (qty > 0 && _selectedStock != null && _selectedUnit != null) {
                widget.onAdd(_selectedStock!, qty, _selectedUnit!);
                _qtyController.clear();
                setState(() {
                  _selectedStock = null;
                  _selectedUnit = null;
                });
              }
            },
            child: const Text('Add Material'),
          ),
        ],
      ],
    );
  }
}
