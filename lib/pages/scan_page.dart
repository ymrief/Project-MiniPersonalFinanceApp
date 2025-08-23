import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../db/database_helper.dart';
import '../models/receipt.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  String _extractedText = "";
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _processImage(File(pickedFile.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _loading = true);
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() {
      _extractedText = recognizedText.text;
      _loading = false;
    });
  }

  Future<void> _saveToHistory() async {
    if (_extractedText.isEmpty) return;

    final receipt = Receipt(
      title: "Struk Belanja",
      content: _extractedText,
      total: _parseTotal(_extractedText),
      date: DateTime.now().toIso8601String(),
      category: _detectCategoryFromText(_extractedText),
    );

    await DatabaseHelper.instance.insertReceipt(receipt);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Struk berhasil disimpan")),
    );
    Navigator.pop(context); // balik ke Home biar list auto refresh
  }

  double _parseTotal(String text) {
    // ambil angka terakhir yang terlihat seperti uang (titik/koma)
    final regex = RegExp(r'(\d{1,3}([.,]\d{3})*[.,]\d{2})|(\d{1,3}([.,]\d{3})+)');
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      final raw = matches.last.group(0)!;
      final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    }
    return 0.0;
  }

  String _detectCategoryFromText(String t) {
    final s = t.toLowerCase();
    bool hasAny(List<String> keys) => keys.any((k) => s.contains(k));

    if (hasAny(['indomie', 'mie', 'beras', 'susu', 'minyak', 'roti', 'teh', 'kopi', 'snack', 'gula'])) {
      return 'Makanan & Minuman';
    } else if (hasAny(['sabun', 'detergen', 'pewangi', 'tissue', 'baygon', 'sikat', 'pel', 'pembersih'])) {
      return 'Kebutuhan Rumah';
    } else if (hasAny(['pertalite', 'pertamax', 'shell', 'bbm', 'bensin', 'parkir', 'grab', 'gojek'])) {
      return 'Transportasi';
    } else if (hasAny(['pulsa', 'paket data', 'telkomsel', 'xl', 'indosat', 'wifi', 'indihome'])) {
      return 'Komunikasi';
    } else if (hasAny(['obat', 'paracetamol', 'vitamin', 'apotek', 'masker'])) {
      return 'Kesehatan';
    }
    return 'Lainnya';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Struk")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _image != null
              ? Image.file(_image!, height: 200)
              : const Icon(Icons.receipt_long, size: 120, color: Colors.grey),
          const SizedBox(height: 20),
          if (_loading) const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(_extractedText.isEmpty ? "Belum ada hasil OCR..." : _extractedText),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera),
                label: const Text("Scan"),
              ),
              ElevatedButton.icon(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.save),
                label: const Text("Simpan"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
