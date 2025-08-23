import 'package:flutter/material.dart';
import 'ocr_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR Struk App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OCRPage(),
    );
  }
}
