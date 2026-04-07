import 'package:flutter/material.dart';

class UnitDropdown extends StatelessWidget {
  final List<String> units;
  final String? selectedUnit;
  final ValueChanged<String?> onChanged;

  const UnitDropdown({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Deduplicate units to avoid multiple items with same value
    final uniqueUnits = units.toSet().toList();
    return DropdownButton<String>(
      value: selectedUnit,
      items: uniqueUnits
          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
          .toList(),
      onChanged: onChanged,
      hint: const Text('Select unit'),
    );
  }
}
