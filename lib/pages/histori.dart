import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisense/pages/detail.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart';

// Impor file classification.dart Anda
import 'package:nutrisense/utils/classification.dart'; // Sesuaikan path jika berbeda

class HistoriPage extends StatefulWidget {
  @override
  _HistoriPageState createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true; // Tambahkan state loading

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() {
      _isLoading = true; // Set loading true saat mulai fetch
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('predictions')
            .orderBy('timestamp', descending: true)
            .limit(25)
            .get();

        final predictions = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Tambahkan id dokumen ke dalam data
          return data;
        }).toList();

        if (mounted) {
          setState(() {
            _predictions = predictions;
            _isLoading = false; // Set loading false setelah data didapat
          });
        }
      } else {
        print('Tidak ada pengguna yang login.');
        if (mounted) {
          setState(() {
            _isLoading = false; // Set loading false jika tidak ada user
          });
        }
      }
    } catch (e) {
      print('Error fetching history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading false jika ada error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat histori: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Pastikan AppBar berwarna putih
        elevation: 0, // Hapus shadow AppBar
        leading: IconButton( // Tombol kembali
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          "Riwayat Scan", // Ubah judul
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Pastikan warna teks hitam
          ),
        ),
      ),
      body: _isLoading // Tampilkan loading indicator saat data sedang diambil
          ? const Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
              ? const Center(child: Text('Tidak ada riwayat scan.')) // Pesan jika kosong
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Sesuaikan padding
                  itemCount: _predictions.length,
                  separatorBuilder: (context, index) => Divider( // Garis pemisah tipis
                    color: Colors.grey[300],
                    height: 1,
                    thickness: 0.5,
                    indent: 0, // Pastikan garis penuh dari kiri ke kanan
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    final timestamp = prediction['timestamp'];

                    String formattedDate = 'N/A';
                    String formattedTime = 'N/A';
                    if (timestamp != null) {
                      final dateTime = timestamp.toDate();
                      formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime); // Format tanggal
                      formattedTime = DateFormat('HH:mm').format(dateTime); // Format waktu
                    }

                    final String classificationCode = prediction['prediction'] ?? 'N/A';
                    final String classificationDescription = getClassDescription(classificationCode);

                    return InkWell( // Menggunakan InkWell untuk efek tap
                      onTap: () {
                        final docId = prediction['id'];
                        if (docId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailHistoriPage(documentId: docId),
                            ),
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Detail tidak dapat dimuat: ID dokumen tidak ditemukan.')),
                            );
                          }
                        }
                      },
                      child: Padding( // Tambahkan padding di sini untuk konten ListTile
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding vertikal untuk setiap item
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate, // Tanggal sebagai title
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4), // Spasi antara title dan subtitle
                                  Text(
                                    classificationDescription, // Klasifikasi sebagai subtitle
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Ikon panah
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
