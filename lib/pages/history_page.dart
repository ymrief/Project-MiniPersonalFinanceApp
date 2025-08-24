import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TransactionProvider>(context);
    return prov.loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: prov.loadAll,
      child: prov.transactions.isEmpty
          ? ListView(
        children: [
          SizedBox(height: 200),
          Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Center(child: Text('Belum ada transaksi. Tekan + untuk tambah.')),
        ],
      )
          : ListView.builder(
        itemCount: prov.transactions.length,
        itemBuilder: (context, idx) {
          final t = prov.transactions[idx];
          return ListTile(
            title: Text(t.storeName.isEmpty ? 'Store' : t.storeName),
            subtitle: Text(DateFormat.yMMMd().format(t.date)),
            trailing: Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(t.total)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: t))),
          );
        },
      ),
    );
  }
}
