class WeatherModel {
  final String description;
  final String iconUrl;
  final double temperature;
  final int humidity; 
  final double windSpeed;
  final String windDirect;
  final int cloudCover;
  final String visibility;

  WeatherModel({
    required this.description,
    required this.iconUrl,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirect,
    required this.cloudCover,
    required this.visibility,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      description: json['weather_desc'] ?? '',
      iconUrl: json['image'] ?? '',
      temperature: (json['t'] as num).toDouble(),
      humidity: json['hu'] ?? 0,
      windSpeed: (json['ws'] as num).toDouble(),
      windDirect: json['wd'] ?? '',
      cloudCover: json['tcc'] ?? 0,
      visibility: json['vs_text'] ?? '',
    );
  }
}
