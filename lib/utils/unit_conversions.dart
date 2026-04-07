class UnitConversions {
  // Conversion factors: to convert from [key] unit to [target] unit
  // Example: to convert from 'kilograms' to 'grams', multiply by 1000.
  static final Map<String, Map<String, double>> conversionMap = {
    // Volume conversions (base unit: liters)
    'liters': {
      'liters': 1.0,
      'milliliters': 1000.0,
      'centiliters': 100.0,
      'deciliters': 10.0,
      'gallon': 0.264172,
      'cup': 4.22675,
    },
    'milliliters': {
      'liters': 0.001,
      'milliliters': 1.0,
      'centiliters': 0.1,
      'deciliters': 0.01,
    },
    'centiliters': {
      'liters': 0.01,
      'milliliters': 10.0,
      'centiliters': 1.0,
      'deciliters': 0.1,
    },
    'deciliters': {
      'liters': 0.1,
      'milliliters': 100.0,
      'centiliters': 10.0,
      'deciliters': 1.0,
    },
    'gallon': {
      'liters': 3.78541,
      'milliliters': 3785.41,
      'centiliters': 378.541,
      'deciliters': 37.8541,
    },
    'cup': {
      'liters': 0.236588,
      'milliliters': 236.588,
      'centiliters': 23.6588,
      'deciliters': 2.36588,
    },

    // Weight conversions
    'grams': {
      'grams': 1.0,
      'kilograms': 0.001,
      'milligrams': 1000.0,
      'ounces': 0.035274,
      'pounds': 0.00220462,
    },
    'kilograms': {
      'grams': 1000.0,
      'kilograms': 1.0,
      'milligrams': 1000000.0,
      'ounces': 35.274,
      'pounds': 2.20462,
    },
    'milligrams': {
      'grams': 0.001,
      'kilograms': 0.000001,
      'milligrams': 1.0,
      'ounces': 0.000035274,
      'pounds': 0.00000220462,
    },
    'ounces': {
      'grams': 28.3495,
      'kilograms': 0.0283495,
      'milligrams': 28349.5,
      'ounces': 1.0,
      'pounds': 0.0625,
    },
    'pounds': {
      'grams': 453.592,
      'kilograms': 0.453592,
      'milligrams': 453592,
      'ounces': 16.0,
      'pounds': 1.0,
    },

    // Count-based units (defaults – actual pieces can be customized per stock)
    'tray': {
      'piece': 1.0,
      'dozen': 0.0833333,
      'bundle': 1.0,
    },
    'piece': {
      'piece': 1.0,
      'dozen': 0.0833333,
      'pack': 1.0,
      'box': 1.0,
      'bundle': 1.0,
    },
    'dozen': {
      'piece': 12.0,
      'dozen': 1.0,
      'pack': 12.0,
      'box': 12.0,
      'bundle': 12.0,
    },
    'pack': {
      'piece': 1.0,
      'dozen': 0.0833333,
      'pack': 1.0,
    },
    'box': {
      'piece': 1.0,
      'dozen': 0.0833333,
      'box': 1.0,
    },
    'bundle': {
      'piece': 1.0,
      'dozen': 0.0833333,
      'bundle': 1.0,
    },

    // Length conversions
    'meters': {
      'meters': 1.0,
      'centimeters': 100.0,
      'millimeters': 1000.0,
      'inches': 39.3701,
      'feet': 3.28084,
    },
    'centimeters': {
      'meters': 0.01,
      'centimeters': 1.0,
      'millimeters': 10.0,
      'inches': 0.393701,
      'feet': 0.0328084,
    },
    'millimeters': {
      'meters': 0.001,
      'centimeters': 0.1,
      'millimeters': 1.0,
      'inches': 0.0393701,
      'feet': 0.00328084,
    },
    'inches': {
      'meters': 0.0254,
      'centimeters': 2.54,
      'millimeters': 25.4,
      'inches': 1.0,
      'feet': 0.0833333,
    },
    'feet': {
      'meters': 0.3048,
      'centimeters': 30.48,
      'millimeters': 304.8,
      'inches': 12.0,
      'feet': 1.0,
    },
  };

  static bool canConvert(String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return true;

    if (conversionMap.containsKey(fromUnit) &&
        conversionMap[fromUnit]!.containsKey(toUnit)) {
      return true;
    }

    if (conversionMap.containsKey(toUnit) &&
        conversionMap[toUnit]!.containsKey(fromUnit)) {
      return true;
    }

    return false;
  }

  // Get all compatible units for a given unit
  static List<String> getCompatibleUnits(String unit) {
    // If unit is a key, return its keys
    if (conversionMap.containsKey(unit)) {
      return conversionMap[unit]!.keys.toList();
    }

    // If not, check if it's a value in any map
    for (var entry in conversionMap.entries) {
      if (entry.value.containsKey(unit)) {
        return entry.value.keys.toList();
      }
    }

    // Fallback
    return getAllUnits();
  }

  static double convert({
    required double value,
    required String fromUnit,
    required String toUnit,
    Map<String, int>? customPieces, // from the stock's unitPieces
  }) {
    if (fromUnit == toUnit) return value;

    // Handle count units with custom pieces
    final category = getUnitCategory(fromUnit);
    if (category == 'count') {
      // Convert fromUnit to pieces using customPieces if available
      double fromInPieces;
      if (customPieces != null && customPieces.containsKey(fromUnit)) {
        fromInPieces = value * customPieces[fromUnit]!;
      } else {
        // Fall back to default conversion (assumes 1 piece per unit for pack/box/bundle if not customised)
        // But we need a way to know the base unit? Actually for count units, base is always "piece".
        // So we can convert to pieces via conversionMap if fromUnit is in map and toUnit is piece.
        if (fromUnit == 'piece') {
          fromInPieces = value;
        } else {
          // Use default factor (e.g., 1 pack = 1 piece if no custom? That would be wrong.)
          // Better: if not custom, treat as 1:1? But that would break existing stocks.
          // We'll assume that any stock that uses a count unit will have custom pieces for non‑piece units.
          // For safety, fall back to conversionMap which has defaults (1 pack = 1 piece, etc.)
          fromInPieces = conversionMap[fromUnit]?['piece'] != null
              ? value * conversionMap[fromUnit]!['piece']!
              : value; // fallback
        }
      }

      // Convert from pieces to target unit
      if (toUnit == 'piece') return fromInPieces;
      if (customPieces != null && customPieces.containsKey(toUnit)) {
        return fromInPieces / customPieces[toUnit]!;
      }
      // Fall back to default factor
      if (conversionMap[toUnit]?['piece'] != null) {
        return fromInPieces / conversionMap[toUnit]!['piece']!;
      }
      return fromInPieces; // fallback
    }

    // Non‑count units: use existing logic
    if (conversionMap.containsKey(fromUnit) &&
        conversionMap[fromUnit]!.containsKey(toUnit)) {
      return value * conversionMap[fromUnit]![toUnit]!;
    }
    if (conversionMap.containsKey(toUnit) &&
        conversionMap[toUnit]!.containsKey(fromUnit)) {
      return value / conversionMap[toUnit]![fromUnit]!;
    }
    return value;
  }

  // Get all available units
  static List<String> getAllUnits() {
    final Set<String> allUnits = {};
    for (var entry in conversionMap.entries) {
      allUnits.add(entry.key);
      allUnits.addAll(entry.value.keys);
    }
    return allUnits.toList()..sort();
  }

  // Get unit category
  static String getUnitCategory(String unit) {
    if (getVolumeUnits().contains(unit)) return 'volume';
    if (getWeightUnits().contains(unit)) return 'weight';
    if (getCountUnits().contains(unit)) return 'count';
    if (getLengthUnits().contains(unit)) return 'length';
    return 'other';
  }

  static List<String> getVolumeUnits() =>
      ['liters', 'milliliters', 'centiliters', 'deciliters', 'gallon', 'cup'];

  static List<String> getWeightUnits() =>
      ['grams', 'kilograms', 'milligrams', 'ounces', 'pounds'];

  static List<String> getCountUnits() =>
      ['piece', 'dozen', 'pack', 'box', 'bundle', 'tray'];

  static List<String> getLengthUnits() =>
      ['meters', 'centimeters', 'millimeters', 'inches', 'feet'];

  // Check if units are compatible (same category)
  static bool areUnitsCompatible(String unit1, String unit2) {
    if (unit1 == unit2) return true;
    final category1 = getUnitCategory(unit1);
    final category2 = getUnitCategory(unit2);
    return category1 == category2 && category1 != 'other';
  }
}
