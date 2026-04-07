import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_bloc.dart';
import 'package:profitara/blocs/inventory/inventory_event.dart';
import 'package:profitara/blocs/inventory/inventory_state.dart';
import 'package:profitara/models/stock.dart';
import 'package:profitara/pages/widgets/unit_dropdown.dart';
import 'package:profitara/utils/unit_conversions.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _minStockController = TextEditingController();

  int? _selectedCategoryId;
  String? _baseUnit;
  String? _quantityUnit;
  String? _costUnit;
  String? _minStockUnit;

  // Final selections after confirmation
  List<String> _availableUnits = [];
  final Map<String, int> _unitPieces = {}; // e.g., {'pack': 12, 'box': 24}

  // Temporary selections while editing units
  final Map<String, bool> _tempUnitSelection = {};
  final Map<String, int> _tempUnitPieces = {};

  bool _unitsConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Stock')),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final allUnits = UnitConversions.getAllUnits();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Name field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),

                  // Category dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      items: state.categories
                          .map((c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (id) =>
                          setState(() => _selectedCategoryId = id),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),

                  // Base unit dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _baseUnit,
                    items: allUnits
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(u),
                          ),
                        )
                        .toList(),
                    onChanged: (u) {
                      setState(() {
                        _baseUnit = u;
                        _unitsConfirmed = false;
                        _tempUnitSelection.clear();
                        _tempUnitPieces.clear();
                        _availableUnits = [];
                        _unitPieces.clear();
                        for (var unit in allUnits) {
                          if (UnitConversions.areUnitsCompatible(unit, u!)) {
                            _tempUnitSelection[unit] = false;
                          }
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Base Unit'),
                    validator: (v) => v == null ? 'Required' : null,
                  ),

                  // Available units selection (only shown while not confirmed)
                  if (_baseUnit != null && !_unitsConfirmed) ...[
                    const SizedBox(height: 16),
                    const Text('Select Available Units',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ...allUnits.map((unit) {
                      if (!UnitConversions.areUnitsCompatible(
                          unit, _baseUnit!)) {
                        return const SizedBox.shrink();
                      }

                      final isCountUnit = [
                        'tray',
                        'pack',
                        'box',
                        'bundle',
                        'tray'
                      ].contains(unit);
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: Text(unit),
                            value: _tempUnitSelection[unit] ?? false,
                            onChanged: (checked) {
                              setState(() {
                                _tempUnitSelection[unit] = checked!;
                                if (checked && isCountUnit) {
                                  _tempUnitPieces[unit] ??= 1;
                                } else if (!checked && isCountUnit) {
                                  _tempUnitPieces.remove(unit);
                                }
                              });
                            },
                          ),
                          // Extra input for custom piece count
                          if (_tempUnitSelection[unit] == true && isCountUnit)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 32, bottom: 8),
                              child: TextFormField(
                                initialValue:
                                    _tempUnitPieces[unit]?.toString() ?? '1',
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Pieces per $unit',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  final pieces = int.tryParse(val);
                                  if (pieces != null && pieces > 0) {
                                    setState(() {
                                      _tempUnitPieces[unit] = pieces;
                                    });
                                  }
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Required';
                                  }
                                  final pieces = int.tryParse(val);
                                  if (pieces == null || pieces <= 0) {
                                    return 'Enter a positive number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Validate at least one unit selected
                        final selectedAny =
                            _tempUnitSelection.values.any((v) => v);
                        if (!selectedAny) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Select at least one unit')),
                          );
                          return;
                        }
                        // Validate piece counts for count units
                        bool valid = true;
                        for (var entry in _tempUnitSelection.entries) {
                          if (entry.value &&
                              [
                                'tray',
                                'pack',
                                'box',
                                'bundle',
                              ].contains(entry.key)) {
                            if (!_tempUnitPieces.containsKey(entry.key) ||
                                _tempUnitPieces[entry.key]! <= 0) {
                              valid = false;
                              break;
                            }
                          }
                        }
                        if (!valid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Enter valid piece counts for all selected count units')),
                          );
                          return;
                        }

                        setState(() {
                          _unitPieces.clear();
                          _unitPieces.addAll(_tempUnitPieces);
                          _availableUnits = _tempUnitSelection.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toSet()
                              .toList();
                          // Always include the base unit in the available units
                          if (!_availableUnits.contains(_baseUnit)) {
                            _availableUnits.add(_baseUnit!);
                          }
                          _quantityUnit = _baseUnit;
                          _costUnit = _baseUnit;
                          _minStockUnit = _baseUnit;
                          _unitsConfirmed = true;
                        });
                      },
                      child: const Text('Confirm Units'),
                    ),
                  ],

                  // Quantity, cost, min stock fields (only shown after confirmation)
                  if (_unitsConfirmed) ...[
                    const SizedBox(height: 24),

                    // Quantity row
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration:
                                  const InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          UnitDropdown(
                            units: _availableUnits,
                            selectedUnit: _quantityUnit,
                            onChanged: (u) {
                              print('Quantity unit changed to: $u');
                              setState(() => _quantityUnit = u);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Cost row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration:
                                const InputDecoration(labelText: 'Cost'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        UnitDropdown(
                          units: _availableUnits,
                          selectedUnit: _costUnit,
                          onChanged: (u) => setState(() => _costUnit = u),
                        ),
                      ],
                    ),
                    Text(
                      'Cost will be converted to cost per $_baseUnit',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Minimum stock row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                                labelText: 'Minimum Stock Level'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        UnitDropdown(
                          units: _availableUnits,
                          selectedUnit: _minStockUnit,
                          onChanged: (u) {
                            print('Min stock unit changed to: $u');
                            setState(() => _minStockUnit = u);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save button
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      print('=== SAVING ===');
      print('quantity unit: $_quantityUnit');
      print('cost unit: $_costUnit');
      print('min stock unit: $_minStockUnit');
      print('base unit: $_baseUnit');
      // Convert quantity to base unit
      double qtyInBase = UnitConversions.convert(
        value: double.parse(_quantityController.text),
        fromUnit: _quantityUnit!,
        toUnit: _baseUnit!,
        customPieces: _unitPieces,
      );

      // Convert cost to cost per base unit
      double enteredCost = double.parse(_costController.text);
      double costPerBaseUnit;
      if (_costUnit == _baseUnit) {
        costPerBaseUnit = enteredCost;
      } else {
        double factorToBase = UnitConversions.convert(
          value: 1.0,
          fromUnit: _costUnit!,
          toUnit: _baseUnit!,
          customPieces: _unitPieces,
        );
        costPerBaseUnit = enteredCost / factorToBase;
      }

      // Convert minimum stock to base unit
      double minInBase = UnitConversions.convert(
        value: double.parse(_minStockController.text),
        fromUnit: _minStockUnit!,
        toUnit: _baseUnit!,
        customPieces: _unitPieces,
      );

      final stock = Stock(
        id: 0,
        name: _nameController.text,
        categoryId: _selectedCategoryId!,
        baseUnit: _baseUnit!,
        quantity: qtyInBase,
        costPerBaseUnit: costPerBaseUnit,
        minStockLevel: minInBase,
        availableUnits: _availableUnits,
        unitPieces: _unitPieces,
      );

      context.read<InventoryBloc>().add(AddStock(stock));
      Navigator.pop(context);
    }
  }
}
