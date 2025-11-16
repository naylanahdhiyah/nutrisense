import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert'; 

class PredictionService {
  static Future<String> sendImageForPrediction(File imageFile) async {
    final url = Uri.parse('http://your.url/predict');
    
    final request = http.MultipartRequest('POST', url);
    // request.headers.addAll({'Content-Type': 'multipart/form-data'});

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

        return _parsePredictionResult(responseBody.body);
      } else {

        try {
          final Map<String, dynamic> errorData = json.decode(responseBody.body);
          if (errorData.containsKey('error')) {

            return 'Terjadi kesalahan: ${errorData['error']}';
          } else {

            return 'Terjadi kesalahan server: ${response.statusCode} - ${responseBody.body}';
          }
        } catch (e) {

          return 'Terjadi kesalahan server: ${response.statusCode} - Gagal mengurai respons error: ${responseBody.body}';
        }
      }
    } catch (e) {

      return 'Terjadi kesalahan: Gagal mengirim gambar atau menerima respons: ${e.toString()}';
    }
  }


  static String _parsePredictionResult(String responseBody) {
    try {
      final Map<String, dynamic> decoded = json.decode(responseBody);

      if (decoded.containsKey('result')) {
        return decoded['result'].toString();
      } else {

        return 'Hasil prediksi tidak ditemukan dalam respons: $responseBody';
      }
    } catch (e) {

      return 'Gagal mengurai hasil prediksi: $responseBody. Error: $e';
    }
  }
}
