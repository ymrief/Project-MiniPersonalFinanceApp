import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../services/receipt_parser.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});
  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final picker = ImagePicker();
  String _status = 'Pilih gambar atau ambil foto struk';

  Future<void> _pickImageAndScan() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;
    setState(() => _status = 'Scanning...');
    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await textRecognizer.processImage(inputImage);
      final raw = result.text;
      final parsed = ReceiptParser.parse(raw);
      final transaction = TransactionModel(
        storeName: parsed.storeName,
        date: parsed.date ?? DateTime.now(),
        total: parsed.total ?? parsed.items.fold(0.0, (p, e) => p + e.quantity * e.unitPrice),
        items: parsed.items,
      );
      await Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
      setState(() => _status = 'Sukses disimpan ke riwayat');
      await Future.delayed(Duration(milliseconds: 600));
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _status = 'Gagal: $e');
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Struk')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImageAndScan,
              icon: Icon(Icons.camera_alt),
              label: Text('Ambil Foto Struk'),
            ),
            SizedBox(height: 20),
            Text(_status),
            SizedBox(height: 20),
            Expanded(child: Container()),
            Text('Catatan: parser menggunakan heuristik; jika parsing kurang tepat, edit manual pada riwayat.'),
          ],
        ),
      ),
    );
  }
}
