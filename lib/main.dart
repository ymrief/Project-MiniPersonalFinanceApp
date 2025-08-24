import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/app_database.dart';
import 'providers/transaction_provider.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.getInstance();
  runApp(MyApp(database: db));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider(database)),
      ],
      child: MaterialApp(
        title: 'Mini Personal Finance',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: HomePage(),
      ),
    );
  }
}
