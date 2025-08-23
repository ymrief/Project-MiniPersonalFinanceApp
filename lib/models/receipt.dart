class Receipt {
  int? id;
  String title;
  String content;
  double total;
  String date;

  Receipt({
    this.id,
    required this.title,
    required this.content,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'total': total,
      'date': date,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      total: map['total'],
      date: map['date'],
    );
  }
}
