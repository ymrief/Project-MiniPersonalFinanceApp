import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'history_page.dart';
import 'statistics_page.dart';
import 'scan_receipt_page.dart';
import 'add_manual_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pages = [HistoryPage(), StatisticsPage()];

  void _onFabPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Scan Struk (ML Kit)'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScanReceiptPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Tambah Manual'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddManualPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Personal Finance'),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: AppDrawer(
        onSelect: (idx) {
          setState(() {
            _selectedIndex = idx;
            Navigator.of(context).pop();
          });
        },
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onFabPressed(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
