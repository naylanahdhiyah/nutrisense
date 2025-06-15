import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nutrisense/data/weather.dart';

Future<WeatherModel> fetchWeatherBMKG() async {
  const String url = 'https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=35.78.09.1001';
  final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final weatherJson = data['data'][0]['cuaca'][0][0];
    return WeatherModel.fromJson(weatherJson);
  } else {
    throw Exception('Gagal ambil data (Status: ${response.statusCode})');
  }
}
