import 'package:profitara/database/database_helper.dart';
import 'package:profitara/models/category.dart';
import 'package:profitara/models/stock.dart';
import 'package:sqflite/sqflite.dart';

class StockRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Stock>> getAllStocks() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> stockMaps = await db.query('stocks');
    List<Stock> stocks = [];
    for (var map in stockMaps) {
      final id = map['id'] as int; // cast
      final unitPieces = await _getUnitPieces(id);
      stocks.add(Stock.fromMap(map, unitPieces: unitPieces));
    }
    return stocks;
  }

  Future<Map<String, int>> _getUnitPieces(int stockId) async {
    Database db = await _dbHelper.database;
    final rows = await db
        .query('stock_unit_pieces', where: 'stockId = ?', whereArgs: [stockId]);
    return {
      for (var row in rows) row['unitName'] as String: row['pieces'] as int
    };
  }

  Future<void> insertStock(Stock stock) async {
    Database db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Insert stock without id (auto‑increment)
      final stockMap = stock.toMap();
      stockMap.remove('id'); // remove if 0 or not set
      int id = await txn.insert('stocks', stockMap);
      // Insert unit pieces
      for (var entry in stock.unitPieces.entries) {
        await txn.insert('stock_unit_pieces', {
          'stockId': id,
          'unitName': entry.key,
          'pieces': entry.value,
        });
      }
    });
  }

  Future<void> updateStock(Stock stock) async {
    Database db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update('stocks', stock.toMap(),
          where: 'id = ?', whereArgs: [stock.id]);
      // Replace unit pieces
      await txn.delete('stock_unit_pieces',
          where: 'stockId = ?', whereArgs: [stock.id]);
      for (var entry in stock.unitPieces.entries) {
        await txn.insert('stock_unit_pieces', {
          'stockId': stock.id,
          'unitName': entry.key,
          'pieces': entry.value,
        });
      }
    });
  }

  Future<void> deleteStock(int id) async {
    Database db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Delete related records first
      await txn.delete('waste', where: 'stockId = ?', whereArgs: [id]);
      await txn
          .delete('batch_materials', where: 'stockId = ?', whereArgs: [id]);
      await txn
          .delete('stock_unit_pieces', where: 'stockId = ?', whereArgs: [id]);
      // Finally delete the stock
      await txn.delete('stocks', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Category>> getCategories() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(
        maps.length, (i) => Category(id: maps[i]['id'], name: maps[i]['name']));
  }

  Future<void> addCategory(String name) async {
    Database db = await _dbHelper.database;
    await db.insert('categories', {'name': name});
  }
}
