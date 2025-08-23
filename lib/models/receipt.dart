class Receipt {
  int? id;
  String title;
  String content;
  double total;
  String date;
  String category;

  Receipt({
    this.id,
    required this.title,
    required this.content,
    required this.total,
    required this.date,
    this.category = "Lainnya",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'total': total,
      'date': date,
      'category': category,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      total: (map['total'] is int) ? (map['total'] as int).toDouble() : map['total'],
      date: map['date'],
      category: map['category'] ?? "Lainnya",
    );
  }
}
