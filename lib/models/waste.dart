class WasteEntry {
  int id;
  int stockId;
  double amount;
  DateTime date;

  WasteEntry({
    required this.id,
    required this.stockId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    var map = {
      'stockId': stockId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
    // Only include id if it's not 0 (i.e., not a new record)
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  // fromMap remains the same
  factory WasteEntry.fromMap(Map<String, dynamic> map) {
    return WasteEntry(
      id: map['id'] as int,
      stockId: map['stockId'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
