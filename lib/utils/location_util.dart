import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      return null;
    }
  }

  return await Geolocator.getCurrentPosition();
}

Future<String?> getLocationName(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.locality ?? place.subAdministrativeArea}, ${place.country}';
    }
  } catch (e) {
    print('Gagal mendapatkan nama lokasi: $e');
  }
  return null;
}