import 'package:flutter/material.dart';
import 'package:nutrisense/data/weather.dart';
import 'package:nutrisense/pages/constant.dart';
import 'package:intl/intl.dart';

import 'package:nutrisense/utils/location_util.dart';
import 'package:nutrisense/services/weatherAPI.dart'; 
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {

  late Future<WeatherModel> _weatherFuture;
  String _locationName = 'Mengambil lokasi...';

  @override
  void initState() {
    super.initState();
    _weatherFuture = fetchWeatherBMKG();

    
    _loadLocationName();
  }

  
  Future<void> _loadLocationName() async {
    try {
      final location = await getCurrentLocation();
      if (location != null) {
        final name = await getLocationName(location);
        if (name != null && mounted) {
          setState(() {
            _locationName = name;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _locationName = 'Lokasi tidak tersedia';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationName = 'Gagal mengambil lokasi';
        });
      }
    }
  }

  IconData _mapWeatherToIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('cerah') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('berawan') || desc.contains('cloudy')) {
      return Icons.cloud;
    } else if (desc.contains('hujan') || desc.contains('rain')) {
      return Icons.cloudy_snowing;
    } else if (desc.contains('badai') || desc.contains('storm')) {
      return Icons.thunderstorm;
    } else {
      return Icons.wb_cloudy;
    }
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: _weatherFuture, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            height: 150, 
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Gagal memuat cuaca:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          
          final weather = snapshot.data!;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildWeatherContent(weather),
              ),
              const SizedBox(height: 16),
             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildWeatherDetailsRow(weather),
              ),
            ],
          );
        } else {
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(child: Text('Data cuaca tidak tersedia')),
          );
        }
      },
    );
  }

  Widget _buildWeatherContent(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _locationName, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _mapWeatherToIcon(weather.description),
              size: 40,
              color: babyBlue, 
            ),
            const SizedBox(width: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.temperature.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text('°C', style: Theme.of(context).textTheme.labelLarge),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _getFormattedDate(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 18), 
                Icon(icon, color: babyBlue, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              label,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeatherDetail(Icons.opacity, '${weather.humidity} %', 'Kelembaban'),
            _buildWeatherDetail(Icons.air, '${weather.windSpeed.toStringAsFixed(1)} km/h', 'Kcptan Angin'),
            _buildWeatherDetail(Icons.cloud_queue, '${weather.cloudCover} %', 'Tutupan Awan'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Cuaca disinkronkan secara berkala dengan data BMKG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
