import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/receipt.dart';
import 'detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Receipt> _receipts = [];

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    final data = await DatabaseHelper.instance.getReceipts();
    setState(() {
      _receipts = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: _receipts.length,
        itemBuilder: (context, index) {
          final receipt = _receipts[index];
          return ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(receipt.title),
            subtitle: Text("Total: Rp ${receipt.total.toStringAsFixed(2)}"),
            trailing: Text(receipt.date.split("T").first),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(receipt: receipt)),
              );
            },
          );
        },
      ),
    );
  }
}
