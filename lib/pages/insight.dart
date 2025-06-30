import 'package:flutter/material.dart';

class InsightPage extends StatelessWidget {
  const InsightPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Petunjuk Penggunaan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children:  [
            Text(
              "🌾 Cara Menggunakan Aplikasi NutriSense",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),

            StepTile(
              number: 1,
              text: 'Buka aplikasi dan pilih menu “Scan Tanaman”.',
            ),
            StepTile(
              number: 2,
              text: 'Arahkan kamera ke daun padi dengan jelas dan pastikan pencahayaannya cukup.',
            ),
            StepTile(
              number: 3,
              text: 'Kalau sudah pas, tekan tombol centang ✅.',
            ),
            StepTile(
              number: 4,
              text: 'Tunggu sebentar ya... hasil klasifikasinya akan muncul. Jangan lupa pastikan kamu terhubung ke internet.',
            ),
            StepTile(
              number: 5,
              text: 'Setelah hasilnya muncul, kamu bisa: '
                  '\n- Tekan “Lihat Rekomendasi Pemupukan”, atau '
                  '\n- Tekan “Selesai” untuk kembali ke halaman utama.',
            ),
            StepTile(
              number: 6,
              text: 'Kalau kamu pilih “Lihat Rekomendasi Pemupukan”, isi dulu:\n- Nilai GKG (Gabah Kering Giling)\n- Luas sawah kamu',
            ),
            StepTile(
              number: 7,
              text: 'Lalu tekan “Lihat Rekomendasi”.',
            ),
            StepTile(
              number: 8,
              text: 'Tunggu sebentar... dan rekomendasinya akan langsung tampil! 🌱✨',
            ),
          ],
        ),
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  final int number;
  final String text;

  const StepTile({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.green.shade400,
            child: Text(
              number.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
            ),
          ),
        ],
      ),
    );
  }
}
