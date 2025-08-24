import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../models/item_model.dart';

class AppDatabase {
  static Database? _db;
  static AppDatabase? _instance;
  AppDatabase._();

  static Future<AppDatabase> getInstance() async {
    if (_instance != null) return _instance!;
    _instance = AppDatabase._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = p.join(docs.path, 'mini_pf.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_name TEXT,
        date TEXT,
        total REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        name TEXT,
        quantity INTEGER,
        unit_price REAL,
        FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<int> insertTransaction(TransactionModel t) async {
    final id = await _db!.insert('transactions', t.toMap());
    for (var it in t.items) {
      it.transactionId = id;
      await _db!.insert('items', it.toMap());
    }
    return id;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final txs = await _db!.query('transactions', orderBy: 'date DESC');
    List<TransactionModel> results = [];
    for (var row in txs) {
      final items = await _db!.query('items', where: 'transaction_id = ?', whereArgs: [row['id']]);
      final itemObjs = items.map((e) => ItemModel.fromMap(e)).toList();
      results.add(TransactionModel.fromMap(row, items: itemObjs));
    }
    return results;
  }

  Future<void> deleteTransaction(int id) async {
    await _db!.delete('items', where: 'transaction_id = ?', whereArgs: [id]);
    await _db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async => await _db!.close();
}
