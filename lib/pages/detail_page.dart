import 'package:flutter/material.dart';
import '../models/receipt.dart';

class DetailPage extends StatelessWidget {
  final Receipt receipt;

  const DetailPage({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Struk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(receipt.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Tanggal: ${receipt.date.split("T").first}"),
            const SizedBox(height: 10),
            Text("Total: Rp ${receipt.total.toStringAsFixed(2)}"),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(child: Text(receipt.content)),
            ),
          ],
        ),
      ),
    );
  }
}
