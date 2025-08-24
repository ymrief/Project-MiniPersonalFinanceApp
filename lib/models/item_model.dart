class ItemModel {
  int? id;
  int? transactionId;
  String name;
  int quantity;
  double unitPrice;

  ItemModel({
    this.id,
    this.transactionId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> m) {
    return ItemModel(
      id: m['id'] as int?,
      transactionId: m['transaction_id'] as int?,
      name: m['name'] as String? ?? '',
      quantity: (m['quantity'] as num).toInt(),
      unitPrice: (m['unit_price'] as num).toDouble(),
    );
  }
}
