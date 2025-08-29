// docling_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class DoclingService {
  // Use 10.0.2.2 for Android Emulator
  // final String baseUrl = "http://10.0.2.2:8000";
  final String baseUrl = "http://192.168.1.2:8000";

  Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])?.split('/');

    final imageUploadRequest = http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ocr/'),
    );

    request.files.add(await imageUploadRequest);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Provide a more detailed error
      throw Exception('Failed to scan. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}