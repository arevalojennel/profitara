import 'package:profitara/utils/unit_conversions.dart';

class Stock {
  final int id;
  final String name;
  final int categoryId;
  final String baseUnit;
  double quantity;
  final double costPerBaseUnit;
  final double minStockLevel;
  final List<String> availableUnits;
  final Map<String, int> unitPieces;
  double totalAddedQuantity; // 🆕 cumulative total ever added (in base units)
  double wasteQuantity; // total waste (in base units)
  double wasteValue; // total cost of waste

  Stock({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.baseUnit,
    required this.quantity,
    required this.costPerBaseUnit,
    required this.minStockLevel,
    required this.availableUnits,
    required this.unitPieces,
    this.totalAddedQuantity = 0.0, // default to 0
    this.wasteQuantity = 0.0,
    this.wasteValue = 0.0,
  });

  double get stockValue => quantity * costPerBaseUnit; // value of current stock
  double get totalValueAdded =>
      totalAddedQuantity * costPerBaseUnit; // total money spent

  bool get isLowStock => quantity <= minStockLevel;

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'categoryId': categoryId,
      'baseUnit': baseUnit,
      'quantity': quantity,
      'costPerBaseUnit': costPerBaseUnit,
      'minStockLevel': minStockLevel,
      'availableUnits': availableUnits.join(','),
      'totalAddedQuantity': totalAddedQuantity, // 🆕
      'wasteQuantity': wasteQuantity, // 🆕
      'wasteValue': wasteValue, // 🆕
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Stock.fromMap(Map<String, dynamic> map,
      {Map<String, int>? unitPieces}) {
    return Stock(
      id: map['id'] as int,
      name: map['name'] as String,
      categoryId: map['categoryId'] as int,
      baseUnit: map['baseUnit'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      costPerBaseUnit: (map['costPerBaseUnit'] as num).toDouble(),
      minStockLevel: (map['minStockLevel'] as num).toDouble(),
      availableUnits: (map['availableUnits'] as String).split(',').toList(),
      unitPieces: unitPieces ?? {},
      totalAddedQuantity:
          (map['totalAddedQuantity'] as num?)?.toDouble() ?? 0.0,
      wasteQuantity: (map['wasteQuantity'] as num?)?.toDouble() ?? 0.0,
      wasteValue: (map['wasteValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Returns the most appropriate unit and converted value for a given amount (in base unit).
  /// For count units, tries to show an integer quantity, preferring larger units.
  /// For other units, ensures the displayed quantity is at least 1.
  (double converted, String unit) getDisplayForValue(double valueInBase) {
    const double epsilon = 1e-6;
    final category = UnitConversions.getUnitCategory(baseUnit);

    // Sort available units by conversion factor to base unit (ascending: smaller units first)
    List<String> sortedUnits = List.from(availableUnits);
    sortedUnits.sort((a, b) {
      double factorA =
          UnitConversions.convert(value: 1.0, fromUnit: a, toUnit: baseUnit);
      double factorB =
          UnitConversions.convert(value: 1.0, fromUnit: b, toUnit: baseUnit);
      return factorA.compareTo(factorB);
    });

    if (category == 'count') {
      // For count units, sort descending (larger units first) to prefer dozens over pieces
      List<String> countUnits = List.from(availableUnits);
      countUnits.sort((a, b) {
        double factorA = _getConversionFactorToBase(a);
        double factorB = _getConversionFactorToBase(b);
        return factorB.compareTo(factorA); // descending
      });

      // Try to find a unit that gives an integer quantity >= 1
      for (String unit in countUnits) {
        double converted = UnitConversions.convert(
          value: valueInBase,
          fromUnit: 'piece',
          toUnit: unit,
          customPieces: unitPieces,
        );
        // Only accept if value >= 1 and essentially integer
        if (converted >= 1 && (converted - converted.round()).abs() < epsilon) {
          return (converted.roundToDouble(), unit);
        }
      }
      // No suitable larger unit: fall back to smallest unit (pieces)
      double converted = UnitConversions.convert(
        value: valueInBase,
        fromUnit: 'piece',
        toUnit: sortedUnits.first,
        customPieces: unitPieces,
      );
      return (converted, sortedUnits.first);
    } else {
      // For non-count units, ensure converted value >= 1
      for (String unit in sortedUnits) {
        double converted = UnitConversions.convert(
          value: valueInBase,
          fromUnit: baseUnit,
          toUnit: unit,
        );
        if (converted >= 1) {
          return (converted, unit);
        }
      }
      // Fallback: base unit
      return (valueInBase, baseUnit);
    }
  }

  /// Convenience method for quantity display
  (double displayQuantity, String displayUnit) getDisplayQuantity() =>
      getDisplayForValue(quantity);

  double _getConversionFactorToBase(String unit) {
    if (unit == 'piece') return 1.0;
    if (unitPieces.containsKey(unit)) {
      return 1.0 / unitPieces[unit]!; // e.g., 1 pack = 6 pieces → factor = 1/6
    }
    // fallback to default conversion map
    if (UnitConversions.conversionMap[unit]?.containsKey('piece') ?? false) {
      return 1.0 / UnitConversions.conversionMap[unit]!['piece']!;
    }
    return 1.0;
  }
}
