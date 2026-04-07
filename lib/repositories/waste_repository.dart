import 'package:profitara/database/database_helper.dart';
import 'package:profitara/models/waste.dart';
import 'package:sqflite/sqflite.dart';

class WasteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addWaste(WasteEntry waste) async {
    Database db = await _dbHelper.database;
    await db.insert('waste', waste.toMap());
  }

  Future<List<WasteEntry>> getWasteForStock(int stockId) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('waste', where: 'stockId = ?', whereArgs: [stockId]);
    return maps
        .map((m) => WasteEntry(
              id: m['id'],
              stockId: m['stockId'],
              amount: m['amount'],
              date: DateTime.parse(m['date']),
            ))
        .toList();
  }

  Future<double> getTotalWasteValue() async {
    Database db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(w.amount * s.costPerBaseUnit) as total
      FROM waste w
      JOIN stocks s ON w.stockId = s.id
    ''');
    return result.first['total'] as double? ?? 0.0;
  }
}
