import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailPage({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.storeName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(DateFormat.yMMMMd().add_jm().format(transaction.date)),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: transaction.items.length,
                itemBuilder: (context, i) {
                  final it = transaction.items[i];
                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text('x${it.quantity} • ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(it.unitPrice)}'),
                    trailing: Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(it.unitPrice * it.quantity)),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(transaction.total), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction.id!);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.delete),
                label: Text('Hapus'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }
}
