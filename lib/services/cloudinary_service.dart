import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'rrqbvd5r';
  static const String _uploadPreset = 'kasirku';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads an image to Cloudinary using multipart/form-data.
  /// Supports both [File] for Mobile/Desktop and [Uint8List] for Web.
  Future<String?> uploadImage({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    if (imageFile == null && imageBytes == null) return null;

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;

      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: fileName ?? 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? secureUrl = responseData['secure_url'];
        if (kDebugMode) {
          print('Cloudinary Upload Success: $secureUrl');
        }
        return secureUrl;
      } else {
        if (kDebugMode) {
          print('Cloudinary Upload Error: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Cloudinary error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cloudinary Upload Exception: $e');
      }
      rethrow;
    }
  }
}
