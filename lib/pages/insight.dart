import 'package:flutter/material.dart';

class InsightPage extends StatelessWidget {
  const InsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        
        centerTitle: true,
        title: const Text(
          "Petunjuk Penggunaan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            
            Column( 
              children: [
                Icon(Icons.grass, size: 40, color: Colors.green.shade700), 
                const SizedBox(height: 10), 
                Text(
                  "Cara Menggunakan Aplikasi NutriSense",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                  textAlign: TextAlign.center, 
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Selamat datang di panduan penggunaan NutriSense! Ikuti langkah-langkah mudah di bawah ini untuk memulai:",
              style: Theme.of(context).textTheme.bodySmall?.copyWith( 
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center, 
            ),
            const SizedBox(height: 24),

            
            StepTile(
              number: 1,
              text: 'Buka aplikasi dan pilih menu “Scan Tanaman” dari halaman utama.',
            ),
            StepTile(
              number: 2,
              text: 'Arahkan kamera ke daun padi dengan jelas. Pastikan pencahayaan cukup dan gambar tidak buram.',
            ),
            StepTile(
              number: 3,
              text: 'Jika gambar sudah pas, tekan tombol centang ✅ untuk mengambil foto.',
            ),
            StepTile(
              number: 4,
              text: 'Tunggu sebentar... Aplikasi akan memproses gambar. Pastikan Anda terhubung ke internet untuk hasil klasifikasi yang akurat.',
            ),
            StepTile(
              number: 5,
              text: 'Setelah hasil klasifikasi warna daun muncul, Anda memiliki dua pilihan: \n- Tekan “Lihat Rekomendasi Pemupukan” untuk mendapatkan saran pupuk. \n- Tekan “Selesai” untuk kembali ke halaman utama tanpa rekomendasi.',
            ),
            StepTile(
              number: 6,
              text: 'Jika Anda memilih “Lihat Rekomendasi Pemupukan”, Anda perlu mengisi dua informasi penting: \n- Nilai GKG (Gabah Kering Giling) dalam ton. \n- Luas sawah Anda dalam meter persegi (m²).',
            ),
            StepTile(
              number: 7,
              text: 'Setelah mengisi data GKG dan Luas Sawah, tekan tombol “Lihat Rekomendasi”.',
            ),
            StepTile(
              number: 8,
              text: 'Tunggu sebentar... dan rekomendasi pupuk urea yang disesuaikan dengan kondisi tanaman Anda akan langsung tampil! 🌱✨',
            ),
            const SizedBox(height: 24),
            Text(
              "Semoga panduan ini membantu Anda mendapatkan hasil terbaik dari NutriSense!",
              style: Theme.of(context).textTheme.bodySmall?.copyWith( 
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center, 
            ),
            const SizedBox(height: 20),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), 
      padding: const EdgeInsets.all(16.0), 
      decoration: BoxDecoration(
        color: Colors.green.shade50, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [ 
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.shade600, 
            child: Text(
              number.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16), 
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith( 
                color: Colors.black87,
                height: 1.5, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
