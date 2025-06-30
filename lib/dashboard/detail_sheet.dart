import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailBottomSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final geopoint = data['location'] as GeoPoint?;
    final timestamp = data['timestamp']?.toDate()?.toString() ?? 'N/A';
    final warna = data['prediction'] ?? '-';
    final luas = data['luas']?.toString() ?? '-';
    final gkg = data['gkg']?.toString() ?? '-';
    String? rekomendasi = data['rekomendasi'] ?? '-';

    if (rekomendasi != null && rekomendasi.toLowerCase().startsWith('rekomendasi pupuk urea:')) {
      rekomendasi = rekomendasi.substring('rekomendasi pupuk urea:'.length).trim();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.4, 
      minChildSize: 0.2,
      maxChildSize: 0.8, 
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildDetailText('Timestamp', timestamp, context),
                _buildDetailText('Klasifikasi warna', warna, context),
                if (geopoint != null)
                  _buildDetailText('Koordinat', '${geopoint.latitude}, ${geopoint.longitude}', context),
                _buildDetailText('Rekomendasi pupuk urea', rekomendasi ?? '-', context),
                _buildDetailText('Luas sawah', '$luas m2', context),
                _buildDetailText('GKG', '$gkg ton', context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailText(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
