import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/docling_service.dart';

class ScanReceiptDoclingPage extends StatefulWidget {
  @override
  _ScanReceiptDoclingPageState createState() => _ScanReceiptDoclingPageState();
}

class _ScanReceiptDoclingPageState extends State<ScanReceiptDoclingPage> {
  File? _image;
  String _result = 'Scan result will appear here.';
  bool _isLoading = false;
  final _service = DoclingService();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = 'Image selected. Press "Scan" to process.';
      });
    }
  }

  Future<void> _scan() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _result = 'Scanning...';
    });

    try {
      final result = await _service.scanReceipt(_image!);
      setState(() {
        _result = result['text'] ?? 'No text found in the image.';
      });
    } catch (e) {
      setState(() {
        _result = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan with Docling")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _image != null
                ? Image.file(_image!, height: 300, fit: BoxFit.contain)
                : Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text("Pick an image to scan")),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImage,
              child: Text("Pick Image from Camera"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading || _image == null ? null : _scan,
              child: _isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              )
                  : Text("Scan with Docling"),
            ),
            const SizedBox(height: 16),
            Text("Result:", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(child: SelectableText(_result)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}