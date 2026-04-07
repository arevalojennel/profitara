import 'package:profitara/database/database_helper.dart';
import 'package:profitara/models/batch.dart';
import 'package:profitara/models/production_run.dart';
import 'package:sqflite/sqflite.dart' hide Batch;

class BatchRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Batch>> getAllBatches() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> batchMaps = await db.query('batches');
    List<Batch> batches = [];
    for (var map in batchMaps) {
      final materials = await getBatchMaterials(map['id'] as int);
      batches.add(Batch(
        id: map['id'] as int,
        name: map['name'] as String,
        created: DateTime.parse(map['created'] as String),
        materials: materials,
        piecesYield: map['piecesYield'] as int,
        profitMargin: (map['profitMargin'] as num).toDouble(),
        recommendedSellingPrice:
            (map['recommendedSellingPrice'] as num).toDouble(),
        producedCount: map['producedCount'] as int,
      ));
    }
    return batches;
  }

  Future<List<BatchMaterial>> getBatchMaterials(int batchId) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'batch_materials',
      where: 'batchId = ?',
      whereArgs: [batchId],
    );
    return maps
        .map((m) => BatchMaterial(
              stockId: m['stockId'] as int,
              quantity: (m['quantity'] as num).toDouble(),
              unitName: m['unitName'] as String,
            ))
        .toList();
  }

  Future<void> insertBatch(Batch batch) async {
    Database db = await _dbHelper.database;
    try {
      await db.transaction((txn) async {
        final batchMap = batch.toMap();
        int id = await txn.insert('batches', batchMap);
        for (var material in batch.materials) {
          await txn.insert('batch_materials', {
            'batchId': id,
            'stockId': material.stockId,
            'quantity': material.quantity,
            'unitName': material.unitName,
          });
        }
      });
    } catch (e, stack) {
      print('Error inserting batch: $e');
      print(stack);
      rethrow;
    }
  }

  Future<void> updateBatch(Batch batch) async {
    Database db = await _dbHelper.database;
    await db.update(
      'batches',
      batch.toMap(),
      where: 'id = ?',
      whereArgs: [batch.id],
    );
  }

  Future<Batch> getBatch(int id) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'batches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('Batch not found');
    final map = maps.first;
    final materials = await getBatchMaterials(id);
    return Batch(
      id: map['id'] as int,
      name: map['name'] as String,
      created: DateTime.parse(map['created'] as String),
      materials: materials,
      piecesYield: map['piecesYield'] as int,
      profitMargin: (map['profitMargin'] as num).toDouble(),
      recommendedSellingPrice:
          (map['recommendedSellingPrice'] as num).toDouble(),
      producedCount: map['producedCount'] as int,
    );
  }

  Future<void> addProductionRun(
    int batchId,
    int multiplier,
    double profit,
    double revenue,
    double materialCost,
    int totalYield,
  ) async {
    Database db = await _dbHelper.database;
    await db.insert('production_runs', {
      'batchId': batchId,
      'multiplier': multiplier,
      'profit': profit,
      'revenue': revenue,
      'date': DateTime.now().toIso8601String(),
      'actualSold': totalYield,
      'materialCost': materialCost,
    });
  }

  Future<List<ProductionRun>> getAllProductionRuns() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> runs = await db.query(
      'production_runs',
      orderBy: 'date DESC',
    );
    List<ProductionRun> result = [];
    for (var run in runs) {
      final batch = await getBatch(run['batchId'] as int);
      result.add(ProductionRun.fromMap(run, batch.name));
    }
    return result;
  }

  Future<void> updateProductionRun(ProductionRun run) async {
    Database db = await _dbHelper.database;
    await db.update(
      'production_runs',
      run.toMap(),
      where: 'id = ?',
      whereArgs: [run.id],
    );
  }

  // Statistics methods
  Future<int> getTotalBatchesProduced() async {
    Database db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(producedCount) as total FROM batches',
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getTotalProductionRuns() async {
    Database db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM production_runs',
    );
    return result.first['count'] as int;
  }

  Future<Map<String, dynamic>?> getMostProfitableBatch() async {
    Database db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT b.name, SUM(pr.profit) as totalProfit
      FROM production_runs pr
      JOIN batches b ON pr.batchId = b.id
      GROUP BY pr.batchId
      ORDER BY totalProfit DESC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return {
      'name': result.first['name'] as String,
      'profit': result.first['totalProfit'] as double,
    };
  }
}
