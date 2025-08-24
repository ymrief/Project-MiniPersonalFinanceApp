import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddManualPage extends StatefulWidget {
  const AddManualPage({super.key});
  @override
  _AddManualPageState createState() => _AddManualPageState();
}

class _AddManualPageState extends State<AddManualPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeCtrl = TextEditingController();
  final List<ItemModel> _items = [];

  void _addItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tambah Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama')),
            TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: 'Jumlah'), keyboardType: TextInputType.number),
            TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Harga satuan'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text) ?? 1;
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              if (name.isNotEmpty) {
                setState(() {
                  _items.add(ItemModel(name: name, quantity: qty, unitPrice: price));
                });
                Navigator.of(context).pop();
              }
            },
            child: Text('Tambah'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _storeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Manual')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _storeCtrl, decoration: InputDecoration(labelText: 'Nama Toko')),
              SizedBox(height: 12),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(onPressed: _addItemDialog, icon: Icon(Icons.add), label: Text('Item')),
                      ],
                    ),
                    Expanded(
                      child: _items.isEmpty
                          ? Center(child: Text('Belum ada item'))
                          : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final it = _items[i];
                          return ListTile(
                            title: Text(it.name),
                            subtitle: Text('x${it.quantity} • ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(it.unitPrice)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => setState(() => _items.removeAt(i)),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final total = _items.fold(0.0, (p, e) => p + e.quantity * e.unitPrice);
                        final t = TransactionModel(storeName: _storeCtrl.text.trim(), date: DateTime.now(), total: total, items: _items);
                        await Provider.of<TransactionProvider>(context, listen: false).addTransaction(t);
                        Navigator.of(context).pop();
                      },
                      child: Text('Simpan'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
