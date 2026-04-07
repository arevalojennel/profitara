import 'unit_conversions.dart';

class UnitConverter {
  static double convertToBase(
    double value,
    String unit,
    String baseUnit, {
    Map<String, int>? customPieces,
  }) {
    return UnitConversions.convert(
      value: value,
      fromUnit: unit,
      toUnit: baseUnit,
      customPieces: customPieces,
    );
  }

  static double convertFromBase(
    double baseValue,
    String fromBaseUnit,
    String targetUnit, {
    Map<String, int>? customPieces,
  }) {
    return UnitConversions.convert(
      value: baseValue,
      fromUnit: fromBaseUnit,
      toUnit: targetUnit,
      customPieces: customPieces,
    );
  }

  static bool canConvert(String unit1, String unit2) {
    return UnitConversions.canConvert(unit1, unit2);
  }

  static List<String> getCompatibleUnits(String unit) {
    return UnitConversions.getCompatibleUnits(unit);
  }
}
