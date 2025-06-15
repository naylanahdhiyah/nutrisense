import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisense/pages/constant.dart';
import 'package:nutrisense/services/prediction.dart';
import 'package:nutrisense/services/firebase_service.dart';
import 'package:nutrisense/utils/location_util.dart';
import 'package:nutrisense/data/inputdata.dart';
import 'package:nutrisense/data/recommendation.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _prediction = 'Belum ada prediksi';

  final TextEditingController _luasController = TextEditingController();
  final TextEditingController _gkgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSourceSheet();
    });
  }

  @override
  void dispose() {
    _luasController.dispose();
    _gkgController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> handlePrediction() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    if (_gkgController.text.isEmpty || _luasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan isi GKG dan Luas Sawah')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PredictionService.sendImageForPrediction(_selectedImage!);
      final location = await getCurrentLocation();

      final double luasMeter = double.tryParse(_luasController.text) ?? 0.0;
      final int gkg = int.tryParse(_gkgController.text) ?? 0;

      final rekomendasi = getUreaRecommendation(result, gkg, luasMeter);

      await FirebaseService.uploadResultToFirebase(
        result,
        location,
        gkg: gkg.toDouble(),
        luas: luasMeter,
        rekomendasi: rekomendasi,
      );

      setState(() {
        _isLoading = false;
        _prediction = result + '\n' + rekomendasi;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prediction = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Scan Tanaman",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null) ...[
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              SawahInputFields(
                gkgController: _gkgController,
                luasController: _luasController,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Pindai Tanaman',
                      onPressed: handlePrediction,
                    ),
              SizedBox(height: 30),
            ],
            if (_prediction != null && _prediction != 'Belum ada prediksi')
              Card(
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
                          'Klasifikasi Warna: $_prediction',
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
    );
  }
}
