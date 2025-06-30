import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetailHistoriPage extends StatefulWidget {
  final String documentId;

  DetailHistoriPage({required this.documentId});

  @override
  _DetailHistoriPageState createState() => _DetailHistoriPageState();
}

class _DetailHistoriPageState extends State<DetailHistoriPage> {
  String? prediction;
  DateTime? timestamp;
  String? rekomendasi;
  String? lokasiTeks;
  LatLng? latLng;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchDetailData();
  }

  Future<void> fetchDetailData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .doc(widget.documentId)
          .get();

      if (!docSnapshot.exists) {
        setState(() {
          errorMsg = "Data tidak ditemukan";
          isLoading = false;
        });
        return;
      }

      final data = docSnapshot.data()!;
      prediction = data['prediction'];
      timestamp = data['timestamp'].toDate();
      rekomendasi = data['rekomendasi'];

      final lokasiRaw = data['location'];

      if (lokasiRaw is GeoPoint) {
        latLng = LatLng(lokasiRaw.latitude, lokasiRaw.longitude);
        lokasiTeks = await _getPlaceName(lokasiRaw.latitude, lokasiRaw.longitude);
      } else if (lokasiRaw is String) {
        // Kalau masih string, kamu bisa tulis parsing manual di sini kalau perlu
        lokasiTeks = lokasiRaw;
      } else {
        lokasiTeks = "Lokasi tidak tersedia";
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Terjadi kesalahan: $e";
        isLoading = false;
      });
    }
  }



    Future<String> _getPlaceName(double lat, double lng) async {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      } else {
        return "Lokasi tidak ditemukan";
      }
    }

  Widget buildMap() {
    if (latLng == null) return SizedBox();

    return SizedBox(
      height: 250,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: latLng!,
          initialZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: latLng!,
                width: 60,
                height: 60,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      centerTitle: true,
      title: const Text(
        "Detail Histori",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMsg != null
            ? Center(
                child: Text(
                  errorMsg!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prediksi: $prediction",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Waktu: $timestamp",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Lokasi: $lokasiTeks",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$rekomendasi",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 16),
                    buildMap(),
                  ],
                ),
              ),
  );
}

}
