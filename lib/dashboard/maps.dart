import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Maps extends StatelessWidget {
  const Maps({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('location').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada data lokasi'));
        }

        final markers = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final geopoint = data['location'];

          if (geopoint is GeoPoint) {
            final lat = geopoint.latitude;
            final lng = geopoint.longitude;

            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lat, lng),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context, 
                    builder: (context) => DetailBottomSheet(data: data),
                    );
                },
              
              child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
              ),
            );
          }

          return null;
        }).whereType<Marker>().toList();

        return FlutterMap(
          mapController: MapController(),
          options: const MapOptions(
            initialCenter: LatLng(-7.2883, 112.7985), // Surabaya
            initialZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}

class DetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailBottomSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final geopoint = data['location'] as GeoPoint;
    final timestamp = data['timestamp']?.toDate().toString() ?? 'N/A';
    final warna = data['prediction'] ?? 'Tidak ada';
    // final lokasi = data['alamat'] ?? 'Tidak ada';
    final luas = data['luas'] ?? '-';
    final gkg = data['gkg'] ?? '-';
    final rekomendasi = data['rekomendasi'] ?? '-';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Timestamp: $timestamp'),
          Text('Klasifikasi warna: $warna'),
          // Text('Lokasi: $lokasi'),
          Text('Koordinat: ${geopoint.latitude}, ${geopoint.longitude}'),
          Text('Rekomendasi pupuk urea: $rekomendasi'),
          Text('Luas sawah: $luas m2'),
          Text('GKG: $gkg ton'),
        ],
      ),
    );
  }
}

