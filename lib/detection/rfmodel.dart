import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
// import 'package:nutrisense/data/detail.dart';
import 'package:nutrisense/pages/constant.dart';
// import 'package:nutrisense/pages/histori.dart';
import 'package:nutrisense/pages/dashboard.dart';
import 'package:nutrisense/data/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nutrisense/interface/navbar.dart';
import 'package:nutrisense/pages/histori.dart';

class ImagePredictionPage extends StatefulWidget {
  @override
  _ImagePredictionPageState createState() => _ImagePredictionPageState();
}

class _ImagePredictionPageState extends State<ImagePredictionPage> {
  String? _prediction = 'Belum ada prediksi';
  bool _isLoading = false;
  File? _selectedImage;

  // Fungsi untuk memilih gambar dari galeri
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengirim gambar ke server
  Future<void> sendImageForPrediction(File imageFile) async {
    final url = Uri.parse('http://192.168.2.119:5000/predict');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Content-Type': 'multipart/form-data'});

    final mimeType = lookupMimeType(imageFile.path);
    final file = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
    );
    request.files.add(file);

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final result = responseBody.body;

        setState(() {
          _isLoading = false;
          _prediction = _parsePrediction(result); // parse JSON
        });

        // Upload hasil prediksi ke Firebase
        await uploadResultToFirebase(_prediction!);
      } else {
        setState(() {
          _isLoading = false;
          _prediction = 'Gagal mendapatkan hasil dari server';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prediction = 'Terjadi kesalahan: $e';
      });
    }
  }

  // Fungsi parsing hasil JSON prediksi
  String _parsePrediction(String responseBody) {
    try {
      final decoded = responseBody.contains('result')
          ? responseBody.split('"result":')[1].split('"')[1]
          : responseBody;
      return decoded;
    } catch (e) {
      return responseBody; // fallback
    }
  }

  
  Future<void> uploadResultToFirebase(String prediction) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User tidak terautentikasi');
        return;
      }
      final userId = user.uid;

      Position? position = await getCurrentLocation();

      String location = position != null
        ? 'Latitude: ${position.latitude}, Longitude: ${position.longitude}'
        : 'Lokasi tidak ditemukan';

      await firestore.collection('users').doc(userId).collection('predictions').add({
        'prediction': prediction,
        'timestamp': FieldValue.serverTimestamp(),
        'location': location,
      });

      print('Data berhasil disimpan ke Firebase Firestore');
    } catch (e) {
      print('Gagal menyimpan ke Firestore: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        "Scan Tanaman",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage == null) ...[
              SecondaryButton(
                text: 'Pilih dari Galeri',
                onPressed: pickImageFromGallery,
              ),
              SizedBox(height: 10),
              SecondaryButton(
                text: 'Ambil dari Kamera',
                onPressed: pickImageFromCamera,
              ),
            ] else ...[
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : PrimaryButton(
                      text: 'Pindai Tanaman',
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        sendImageForPrediction(_selectedImage!);
                      },
                    ),
            ],
            SizedBox(height: 30),
            if (_prediction != null && _prediction != 'Belum ada prediksi') 
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hasil Prediksi: $_prediction',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: BottomNav(
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) return;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HistoriPage()),
          );
        }
      },
    ),
  );
}
}