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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _processImage(File(pickedFile.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognizedText.text;
    });

    textRecognizer.close();
  }

  Future<void> _saveToHistory() async {
    if (_extractedText.isEmpty) return;

    final receipt = Receipt(
      title: "Struk Belanja",
      content: _extractedText,
      total: _parseTotal(_extractedText),
      date: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertReceipt(receipt);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Struk berhasil disimpan")),
    );
  }

  double _parseTotal(String text) {
    final regex = RegExp(r'(\d+[.,]\d{2})');
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      return double.tryParse(matches.last.group(0)!.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(_extractedText),
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
