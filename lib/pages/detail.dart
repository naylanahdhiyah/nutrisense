import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

// Impor file classification.dart Anda
import 'package:nutrisense/utils/classification.dart'; // Sesuaikan path jika berbeda

class DetailHistoriPage extends StatefulWidget {
  final String documentId;

  DetailHistoriPage({super.key, required this.documentId}); // Tambahkan super.key

  @override
  _DetailHistoriPageState createState() => _DetailHistoriPageState();
}

class _DetailHistoriPageState extends State<DetailHistoriPage> {
  String? predictionCode; // Mengubah nama variabel untuk menyimpan kode asli
  DateTime? timestamp;
  String? rekomendasi;
  GeoPoint? location;
  double? gkg;
  double? luas;
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
      // Pastikan pengguna login sebelum mencoba mendapatkan UID
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            errorMsg = "Pengguna tidak login.";
            isLoading = false;
          });
        }
        return;
      }
      final userId = currentUser.uid;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .doc(widget.documentId)
          .get();

      if (!docSnapshot.exists) {
        if (mounted) {
          setState(() {
            errorMsg = "Data tidak ditemukan";
            isLoading = false;
          });
        }
        return;
      }

      final data = docSnapshot.data()!;
      predictionCode = data['prediction']; // Simpan kode asli di predictionCode
      timestamp = data['timestamp']?.toDate();
      rekomendasi = data['rekomendasi'];
      if (rekomendasi != null && rekomendasi!.toLowerCase().startsWith('rekomendasi pupuk urea:')) {
        rekomendasi = rekomendasi!.substring('rekomendasi pupuk urea:'.length).trim();
      }
      location = data['location'];
      gkg = (data['gkg'] as num?)?.toDouble();
      luas = (data['luas'] as num?)?.toDouble();

      if (location is GeoPoint) {
        final geo = location as GeoPoint;
        latLng = LatLng(geo.latitude, geo.longitude);
        lokasiTeks = await _getPlaceName(geo.latitude, geo.longitude);
      } else {
        lokasiTeks = "Lokasi tidak tersedia";
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Terjadi kesalahan: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<String> _getPlaceName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Membangun alamat yang lebih lengkap dan mudah dibaca
        return [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      } else {
        return "Lokasi tidak ditemukan";
      }
    } catch (e) {
      print('Error getting place name: $e');
      return "Gagal mendapatkan nama lokasi";
    }
  }

  Widget buildMap() {
    if (latLng == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Peta tidak tersedia', style: Theme.of(context).textTheme.bodySmall),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: latLng!,
            initialZoom: 16,
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
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = timestamp != null
        ? DateFormat('MMM dd, yyyy \'at\' h:mm:ss a').format(timestamp!)
        : 'N/A';

    // Dapatkan deskripsi klasifikasi warna menggunakan fungsi
    final String classificationDisplay =
        predictionCode != null ? getClassDescription(predictionCode!) : 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Detail Riwayat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!, style: Theme.of(context).textTheme.bodySmall))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildMap(),
                      const SizedBox(height: 16),
                      buildDetailItem("Timestamp", formattedTime),
                      // Gunakan classificationDisplay di sini
                      buildDetailItem("Klasifikasi warna", classificationDisplay),
                      buildDetailItem("Rekomendasi pupuk urea", rekomendasi ?? 'N/A'),
                      buildDetailItem(
                        "Koordinat Lokasi",
                        location != null
                            ? "${location!.latitude.toStringAsFixed(6)}, ${location!.longitude.toStringAsFixed(6)}"
                            : 'N/A',
                      ),
                      buildDetailItem("Alamat", lokasiTeks ?? 'N/A'), // Menambahkan detail alamat
                      buildDetailItem("Luas Sawah", luas != null ? "${luas!.toStringAsFixed(0)} m2" : 'N/A'),
                      buildDetailItem("GKG", gkg != null ? "${gkg!.toStringAsFixed(1)} ton" : 'N/A'),
                    ],
                  ),
                ),
    );
  }
}
