class ProductionRun {
  final int id;
  final int batchId;
  final String batchName; // for display, not stored
  final int multiplier;
  double profit;
  double revenue;
  final DateTime date;
  int actualSold;
  final double materialCost;

  ProductionRun({
    required this.id,
    required this.batchId,
    required this.batchName,
    required this.multiplier,
    required this.profit,
    required this.revenue,
    required this.date,
    required this.actualSold,
    required this.materialCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'multiplier': multiplier,
      'profit': profit,
      'revenue': revenue,
      'date': date.toIso8601String(),
      'actualSold': actualSold,
      'materialCost': materialCost,
    };
  }

  factory ProductionRun.fromMap(Map<String, dynamic> map, String batchName) {
    return ProductionRun(
      id: map['id'],
      batchId: map['batchId'],
      batchName: batchName,
      multiplier: map['multiplier'],
      profit: map['profit'],
      revenue: map['revenue'],
      date: DateTime.parse(map['date']),
      actualSold: map['actualSold'] ?? 0,
      materialCost: map['materialCost'],
    );
  }
}
