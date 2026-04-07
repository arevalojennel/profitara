class BatchMaterial {
  final int stockId;
  final double quantity; // in selected unit
  final String unitName; // e.g., 'kilograms'

  BatchMaterial(
      {required this.stockId, required this.quantity, required this.unitName});

  Map<String, dynamic> toMap() => {
        'stockId': stockId,
        'quantity': quantity,
        'unitName': unitName,
      };
}

class Batch {
  final int id;
  final String name;
  final DateTime created;
  final List<BatchMaterial> materials;
  final int piecesYield; // renamed from 'yield'
  final double profitMargin; // e.g., 20.0 for 20%
  final double recommendedSellingPrice; // per piece
  int producedCount;

  Batch({
    required this.id,
    required this.name,
    required this.created,
    required this.materials,
    required this.piecesYield,
    required this.profitMargin,
    required this.recommendedSellingPrice,
    this.producedCount = 0,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'created': created.toIso8601String(),
      'piecesYield': piecesYield,
      'profitMargin': profitMargin,
      'recommendedSellingPrice': recommendedSellingPrice,
      'producedCount': producedCount,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'],
      name: map['name'],
      created: DateTime.parse(map['created']),
      materials: [], // materials are loaded separately
      piecesYield: map['piecesYield'],
      profitMargin: map['profitMargin'],
      recommendedSellingPrice: map['recommendedSellingPrice'],
      producedCount: map['producedCount'],
    );
  }
}
