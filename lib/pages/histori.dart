import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisense/pages/detail.dart'; 


import 'package:nutrisense/utils/classification.dart';

class HistoriPage extends StatefulWidget {
  @override
  _HistoriPageState createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() {
      _isLoading = true; 
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
          data['id'] = doc.id; 
          return data;
        }).toList();

        if (mounted) {
          setState(() {
            _predictions = predictions;
            _isLoading = false; 
          });
        }
      } else {
        print('Tidak ada pengguna yang login.');
        if (mounted) {
          setState(() {
            _isLoading = false; 
          });
        }
      }
    } catch (e) {
      print('Error fetching history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; 
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
        backgroundColor: Colors.white, 
        elevation: 0, 
        leading: IconButton( 
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          "Riwayat Scan", 
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
              ? const Center(child: Text('Tidak ada riwayat scan.')) 
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
                  itemCount: _predictions.length,
                  separatorBuilder: (context, index) => Divider( 
                    color: Colors.grey[300],
                    height: 1,
                    thickness: 0.5,
                    indent: 0, 
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    final timestamp = prediction['timestamp'];

                    String formattedDate = 'N/A';
                    String formattedTime = 'N/A';
                    if (timestamp != null) {
                      final dateTime = timestamp.toDate();
                      formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime); 
                      formattedTime = DateFormat('HH:mm').format(dateTime); 
                    }

                    final String classificationCode = prediction['prediction'] ?? 'N/A';
                    final String classificationDescription = getClassDescription(classificationCode);

                    return InkWell( 
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
                      child: Padding( 
                        padding: const EdgeInsets.symmetric(vertical: 12.0), 
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate, 
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4), 
                                  Text(
                                    classificationDescription, 
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), 
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
