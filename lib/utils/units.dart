class Units {
  static List<String> getAllUnits() {
    return [
      // Volume
      'liters',
      'milliliters',
      'centiliters',
      'deciliters',
      'gallon',
      'cup',

      // Weight
      'grams',
      'kilograms',
      'milligrams',
      'ounces',
      'pounds',

      // Count
      'piece',
      'dozen',
      'pack',
      'box',
      'bundle',

      // Length
      'meters',
      'centimeters',
      'millimeters',
      'inches',
      'feet',

      // Other
      'sheet',
      'roll',
      'tube',
      'bottle',
      'can',
      'jar',
      'bag',
      'packet',
      'sachet',
    ];
  }

  static List<String> getVolumeUnits() {
    return [
      'liters',
      'milliliters',
      'centiliters',
      'deciliters',
      'gallon',
      'cup'
    ];
  }

  static List<String> getWeightUnits() {
    return ['grams', 'kilograms', 'milligrams', 'ounces', 'pounds'];
  }

  static List<String> getCountUnits() {
    return ['piece', 'dozen', 'pack', 'box', 'bundle'];
  }

  static List<String> getLengthUnits() {
    return ['meters', 'centimeters', 'millimeters', 'inches', 'feet'];
  }

  static List<String> getUnitsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'volume':
        return getVolumeUnits();
      case 'weight':
        return getWeightUnits();
      case 'count':
        return getCountUnits();
      case 'length':
        return getLengthUnits();
      default:
        return getAllUnits();
    }
  }
}
