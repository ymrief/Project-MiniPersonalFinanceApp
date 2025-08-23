import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';
import '../models/receipt.dart';
import 'scan_page.dart';
import 'detail_page.dart';
import 'statistic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      appBar: AppBar(
        title: Text("OCR Struk Belanja",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.receipt_long, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text("Menu",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Riwayat"),
              onTap: () {
                Navigator.pop(context);
                // sebenarnya riwayat udah ada di Home, bisa diarahkan ke sini juga
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Statistik"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatistikPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReceipts,
        child: _receipts.isEmpty
            ? Center(
          child: Text(
            "Belum ada struk yang tersimpan",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: _receipts.length,
          itemBuilder: (context, index) {
            final receipt = _receipts[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Colors.blue),
                title: Text(receipt.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                    "Total: Rp ${receipt.total.toStringAsFixed(2)}\n${receipt.date.split("T").first}"),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailPage(receipt: receipt)),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanPage()),
          );
          _loadReceipts(); // reload setelah scan
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
