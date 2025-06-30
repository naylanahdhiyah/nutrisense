import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PredictionService {
  static Future<String> sendImageForPrediction(File imageFile) async {
    final url = Uri.parse('http://192.168.2.103:5000/predict');
    // final url = Uri.parse('http://172.20.10.2:5000/predict'); 
    // final url = Uri.parse('https://41a4-103-24-56-37.ngrok-free.app/predict'); 
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Content-Type': 'multipart/form-data'});

    final mimeType = lookupMimeType(imageFile.path);
    final file = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
    );
    request.files.add(file);

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return _parsePrediction(responseBody.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending image: $e');
    }
  }

  static String _parsePrediction(String responseBody) {
    try {
      final decoded = responseBody.contains('result')
          ? responseBody.split('"result":')[1].split('"')[1]
          : responseBody;
      return decoded;
    } catch (e) {
      return responseBody;
    }
  }
}
