import 'item_model.dart';

class TransactionModel {
  int? id;
  String storeName;
  DateTime date;
  double total;
  List<ItemModel> items;

  TransactionModel({
    this.id,
    required this.storeName,
    required this.date,
    required this.total,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_name': storeName,
      'date': date.toIso8601String(),
      'total': total,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> m, {List<ItemModel>? items}) {
    return TransactionModel(
      id: m['id'] as int?,
      storeName: m['store_name'] as String? ?? '',
      date: DateTime.parse(m['date'] as String),
      total: (m['total'] as num).toDouble(),
      items: items ?? [],
    );
  }
}
