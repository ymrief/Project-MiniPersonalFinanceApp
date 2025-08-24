import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TransactionProvider>(context);
    final monthsBack = 6;
    final months = List.generate(monthsBack, (i) {
      final dt = DateTime(_selected.year, _selected.month - i, 1);
      final total = prov.totalForMonth(dt.year, dt.month);
      return {'date': dt, 'total': total};
    }).reversed.toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selected,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    helpText: 'Pilih bulan',
                    fieldLabelText: 'Bulan',
                    selectableDayPredicate: (dt) => true,
                  );
                  if (picked != null) setState(() => _selected = picked);
                },
                icon: Icon(Icons.calendar_month),
                label: Text(DateFormat.yMMM().format(_selected)),
              )
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: false),
                          barGroups: months.map((m) {
                            final idx = months.indexOf(m);
                            return BarChartGroupData(
                              x: idx,
                              barRods: [BarChartRodData(toY: (m['total'] as double), width: 14)],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total bulan ini'),
                        Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(prov.totalForMonth(_selected.year, _selected.month)))
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
