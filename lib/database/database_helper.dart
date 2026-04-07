// ignore_for_file: unused_import

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:profitara/models/category.dart';
import 'package:profitara/models/stock.dart';
import 'package:profitara/models/batch.dart';
import 'package:profitara/models/waste.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'profitara.db');
    Database db = await openDatabase(
      path,
      version: 10,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Ensure all required columns exist (safe for existing databases)
    await _ensureColumns(db);
    return db;
  }

  Future<void> _ensureColumns(Database db) async {
    // Get current columns in stocks table
    List<Map<String, dynamic>> columns =
        await db.rawQuery('PRAGMA table_info(stocks)');
    List<String> columnNames =
        columns.map((col) => col['name'] as String).toList();

    // Add missing columns one by one
    if (!columnNames.contains('wasteQuantity')) {
      await db.execute(
          'ALTER TABLE stocks ADD COLUMN wasteQuantity REAL DEFAULT 0');
    }
    if (!columnNames.contains('wasteValue')) {
      await db
          .execute('ALTER TABLE stocks ADD COLUMN wasteValue REAL DEFAULT 0');
    }
    if (!columnNames.contains('totalAddedQuantity')) {
      await db.execute(
          'ALTER TABLE stocks ADD COLUMN totalAddedQuantity REAL DEFAULT 0');
    }
  }

  Future _onCreate(Database db, int version) async {
    // Categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Stocks
    db.execute('''
        CREATE TABLE stocks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          categoryId INTEGER,
          baseUnit TEXT,
          quantity REAL,
          costPerBaseUnit REAL,
          minStockLevel REAL,
          availableUnits TEXT,
          totalAddedQuantity REAL DEFAULT 0,  // 🆕
          wasteQuantity REAL DEFAULT 0,
          wasteValue REAL DEFAULT 0
        )
      ''');

    // Batches
    await db.execute('''
      CREATE TABLE batches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created TEXT NOT NULL,
        piecesYield INTEGER NOT NULL,
        profitMargin REAL NOT NULL,
        recommendedSellingPrice REAL NOT NULL,
        producedCount INTEGER DEFAULT 0
      )
    ''');

    // Batch materials
    await db.execute('''
      CREATE TABLE batch_materials(
        batchId INTEGER NOT NULL,
        stockId INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unitName TEXT NOT NULL,
        FOREIGN KEY (batchId) REFERENCES batches (id),
        FOREIGN KEY (stockId) REFERENCES stocks (id)
      )
    ''');

    // Waste
    await db.execute('''
      CREATE TABLE waste(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stockId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (stockId) REFERENCES stocks (id)
      )
    ''');

    // Production runs
    await db.execute('''
      CREATE TABLE production_runs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batchId INTEGER NOT NULL,
        multiplier INTEGER NOT NULL,
        profit REAL NOT NULL,
        revenue REAL NOT NULL,
        date TEXT NOT NULL,
        actualSold INTEGER DEFAULT 0,
        materialCost REAL NOT NULL,
        FOREIGN KEY (batchId) REFERENCES batches (id)
      )
    ''');

    // Stock unit pieces (custom pack/box/bundle sizes)
    await db.execute('''
      CREATE TABLE stock_unit_pieces(
        stockId INTEGER NOT NULL,
        unitName TEXT NOT NULL,
        pieces INTEGER NOT NULL,
        PRIMARY KEY (stockId, unitName),
        FOREIGN KEY (stockId) REFERENCES stocks (id) ON DELETE CASCADE
      )
    ''');

    // Insert default categories
    await db.insert('categories', {'name': 'Raw Material'});
    await db.insert('categories', {'name': 'Packaging'});
    await db.insert('categories', {'name': 'Finished Good'});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to 2: change from old unit ID system to string-based units
    if (oldVersion < 2) {
      // For simplicity, we drop and recreate. In a real app you'd migrate data.
      await db.execute('DROP TABLE IF EXISTS batch_materials');
      await db.execute('DROP TABLE IF EXISTS stocks');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS batches');
      await db.execute('DROP TABLE IF EXISTS waste');
      await db.execute('DROP TABLE IF EXISTS production_runs');
      await _onCreate(db, newVersion);
      return;
    }

    // Migration from version 2 to 3: rename 'yield' column to 'piecesYield' in batches
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE batches RENAME TO batches_old');
      await db.execute('''
        CREATE TABLE batches(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          created TEXT NOT NULL,
          piecesYield INTEGER NOT NULL,
          profitMargin REAL NOT NULL,
          recommendedSellingPrice REAL NOT NULL,
          producedCount INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        INSERT INTO batches (id, name, created, piecesYield, profitMargin, recommendedSellingPrice, producedCount)
        SELECT id, name, created, yield, profitMargin, recommendedSellingPrice, producedCount FROM batches_old
      ''');
      await db.execute('DROP TABLE batches_old');
    }

    // Migration from version 3 to 4: add actualSold and materialCost to production_runs
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE production_runs_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          batchId INTEGER NOT NULL,
          multiplier INTEGER NOT NULL,
          profit REAL NOT NULL,
          revenue REAL NOT NULL,
          date TEXT NOT NULL,
          actualSold INTEGER DEFAULT 0,
          materialCost REAL NOT NULL,
          FOREIGN KEY (batchId) REFERENCES batches (id)
        )
      ''');
      // Copy data from old table, setting actualSold to total theoretical yield (multiplier * piecesYield) and materialCost to 0 initially
      await db.execute('''
        INSERT INTO production_runs_new (id, batchId, multiplier, profit, revenue, date, actualSold, materialCost)
        SELECT 
          pr.id, 
          pr.batchId, 
          pr.multiplier, 
          pr.profit, 
          pr.revenue, 
          pr.date,
          pr.multiplier * b.piecesYield,
          0
        FROM production_runs pr
        JOIN batches b ON pr.batchId = b.id
      ''');
      await db.execute('DROP TABLE production_runs');
      await db
          .execute('ALTER TABLE production_runs_new RENAME TO production_runs');
    }

    // Migration from version 4 to 5: add stock_unit_pieces table
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE stock_unit_pieces(
          stockId INTEGER NOT NULL,
          unitName TEXT NOT NULL,
          pieces INTEGER NOT NULL,
          PRIMARY KEY (stockId, unitName),
          FOREIGN KEY (stockId) REFERENCES stocks (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 6) {
      // Add new columns
      await db.execute(
          'ALTER TABLE stocks ADD COLUMN wasteQuantity REAL DEFAULT 0');
      await db
          .execute('ALTER TABLE stocks ADD COLUMN wasteValue REAL DEFAULT 0');
    }
    if (oldVersion < 7) {
      // 🆕 Add totalAddedQuantity column
      await db.execute(
          'ALTER TABLE stocks ADD COLUMN totalAddedQuantity REAL DEFAULT 0');
    }
  }
}
