import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/database_helper.dart';
import '../models/receipt.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  List<Receipt> _receipts = [];
  final Map<String, double> _categoryTotals = {};
  final Map<String, double> _monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getReceipts();
    _receipts = data;
    _calculateCategoryTotals();
    _calculateMonthlyTotals();
    if (mounted) setState(() {});
  }

  void _calculateCategoryTotals() {
    _categoryTotals.clear();
    for (var r in _receipts) {
      final cat = (r.category.isEmpty) ? "Lainnya" : r.category;
      _categoryTotals[cat] = (_categoryTotals[cat] ?? 0) + r.total;
    }
  }

  void _calculateMonthlyTotals() {
    _monthlyTotals.clear();
    for (var r in _receipts) {
      final month = (r.date.length >= 7) ? r.date.substring(0, 7) : r.date; // "YYYY-MM"
      _monthlyTotals[month] = (_monthlyTotals[month] ?? 0) + r.total;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _receipts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistik Pengeluaran",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: hasData
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pengeluaran per Kategori",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: _buildPieChart()),

            const SizedBox(height: 30),

            Text("Pengeluaran per Bulan",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(height: 240, child: _buildBarChart()),
          ],
        ),
      )
          : Center(
        child: Text(
          "Belum ada data untuk ditampilkan",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_categoryTotals.isEmpty) {
      return const Center(child: Text("Tidak ada data kategori"));
    }

    final palette = <Color>[
      Colors.blueAccent, Colors.orangeAccent, Colors.green,
      Colors.purpleAccent, Colors.redAccent, Colors.teal, Colors.amber
    ];

    final entries = _categoryTotals.entries.toList();
    final sections = List.generate(entries.length, (i) {
      final e = entries[i];
      return PieChartSectionData(
        value: e.value,
        title: e.key,
        radius: 60,
        color: palette[i % palette.length],
        titleStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
      );
    });

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 4,
        centerSpaceRadius: 36,
      ),
    );
  }

  Widget _buildBarChart() {
    if (_monthlyTotals.isEmpty) {
      return const Center(child: Text("Tidak ada data bulanan"));
    }

    final months = _monthlyTotals.keys.toList()..sort();
    final values = months.map((m) => _monthlyTotals[m] ?? 0).toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= months.length) return const SizedBox.shrink();
                // tampilkan "MM"
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(months[i].substring(5),
                      style: GoogleFonts.poppins(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(months.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: values[i],
              width: 18,
              borderRadius: BorderRadius.circular(6),
              color: Colors.blueAccent,
            ),
          ]);
        }),
      ),
    );
  }
}
