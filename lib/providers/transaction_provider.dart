import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final AppDatabase db;
  List<TransactionModel> _transactions = [];
  bool loading = false;

  TransactionProvider(this.db) {
    loadAll();
  }

  List<TransactionModel> get transactions => _transactions;

  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    final appdb = await AppDatabase.getInstance();
    _transactions = await appdb.getAllTransactions();
    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await AppDatabase.getInstance().then((db) => db.insertTransaction(t));
    await loadAll();
  }

  Future<void> deleteTransaction(int id) async {
    await AppDatabase.getInstance().then((db) => db.deleteTransaction(id));
    await loadAll();
  }

  List<TransactionModel> transactionsForMonth(int year, int month) {
    return _transactions.where((t) => t.date.year == year && t.date.month == month).toList();
  }

  double totalForMonth(int year, int month) {
    return transactionsForMonth(year, month).fold(0.0, (p, e) => p + e.total);
  }
}
