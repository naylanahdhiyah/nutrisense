import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisense/pages/detail.dart';


class HistoriPage extends StatefulWidget {
  @override
  _HistoriPageState createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  List<Map<String, dynamic>> _predictions = [];

  Future<void> fetchHistory() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('predictions')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        final predictions = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Tambahkan id dokumen ke dalam data
          return data;
        }).toList();

        setState(() {
          _predictions = predictions;
        });
      } else {
        print('Tidak ada pengguna yang login.');
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Histori",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: _predictions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _predictions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      prediction['prediction'] ?? 'No prediction available',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Waktu: ${prediction['timestamp']?.toDate() ?? 'N/A'}',
                    ),
                    onTap: () {
                      final docId = prediction['id'];
                      if (docId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailHistoriPage(documentId: docId),
                          ),
                        );
                      } else {
                        print('Document ID tidak tersedia.');
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
