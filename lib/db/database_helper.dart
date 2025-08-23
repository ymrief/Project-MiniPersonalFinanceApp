import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('receipts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        total REAL,
        date TEXT,
        category TEXT DEFAULT 'Lainnya'
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE receipts ADD COLUMN category TEXT DEFAULT 'Lainnya'"
      );
    }
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.insert('receipts', receipt.toMap());
  }

  Future<List<Receipt>> getReceipts() async {
    final db = await instance.database;
    final result = await db.query('receipts', orderBy: 'id DESC');
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
