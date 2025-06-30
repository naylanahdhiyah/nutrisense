import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisense/pages/constant.dart'; 
import 'package:nutrisense/services/prediction.dart';
import 'package:nutrisense/services/firebase_service.dart';
import 'package:nutrisense/utils/location_util.dart';
import 'package:nutrisense/data/recommendation.dart'; 
import 'package:nutrisense/pages/dashboard.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _predictionResult; // Stores only the classification result
  String? _fertilizerRecommendation; // Stores the fertilizer recommendation
  bool _showRecommendationInput = false; // Controls visibility of input fields

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
                title: Text(
                  'Ambil dari Kamera',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text(
                  'Pilih dari Galeri',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = null; // Reset prediction when a new image is picked
        _fertilizerRecommendation = null; // Reset recommendation
        _showRecommendationInput = false; // Hide input fields
        _luasController.clear(); // Clear input fields
        _gkgController.clear(); // Clear input fields
      });
      // Automatically send for prediction after image is picked
      _sendImageForPrediction();
    }
  }

  Future<void> _sendImageForPrediction() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null; // Clear previous result
    });

    try {
      final result = await PredictionService.sendImageForPrediction(_selectedImage!);
      setState(() {
        _isLoading = false;
        _predictionResult = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _predictionResult = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  Future<void> _calculateRecommendation() async {
    if (_predictionResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan lakukan prediksi gambar terlebih dahulu')),
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
      final double luasMeter = double.tryParse(_luasController.text) ?? 0.0;
      final int gkg = int.tryParse(_gkgController.text) ?? 0;

      final rekomendasi = getUreaRecommendation(_predictionResult!, gkg, luasMeter);
      final location = await getCurrentLocation(); // Get location here

      await FirebaseService.uploadResultToFirebase(
        _predictionResult!,
        location,
        gkg: gkg.toDouble(),
        luas: luasMeter,
        rekomendasi: rekomendasi,
      );

      setState(() {
        _isLoading = false;
        _fertilizerRecommendation = rekomendasi;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _fertilizerRecommendation = 'Terjadi kesalahan: ${e.toString()}';
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
            SizedBox(height: 16),
          ],

          // 1. Klasifikasi warna
          if (_isLoading && _predictionResult == null)
            Center(child: CircularProgressIndicator())
          else if (_predictionResult != null)
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
                        'Klasifikasi Warna: $_predictionResult',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16),

          // 2. Rekomendasi (jika sudah dihitung)
          if (_fertilizerRecommendation != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.agriculture, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rekomendasi Pemupukan: $_fertilizerRecommendation',
                        style: Theme.of(context).textTheme.bodySmall
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 24),

          // 3. Input Field
          if (_showRecommendationInput)
            Column(
              children: [
                SawahInputFields(
                  gkgController: _gkgController,
                  luasController: _luasController,
                ),
                SizedBox(height: 20),
              ],
            ),

          // 4. Tombol di paling bawah
          SizedBox(height: 20),
          if (_predictionResult != null && !_showRecommendationInput) ...[
            PrimaryButton(
              text: 'Lihat Rekomendasi Pemupukan',
              onPressed: () {
                setState(() {
                  _showRecommendationInput = true;
                  _fertilizerRecommendation = null;
                });
              },
            ),
            SizedBox(height: 10),
            SecondaryButton(
            text: 'Selesai',
            onPressed: () async {
              if (_predictionResult != null) {
                final location = await getCurrentLocation();
                await FirebaseService.uploadResultToFirebase(
                  _predictionResult!,
                  location,
                  gkg: double.tryParse(_gkgController.text) ?? 0.0,
                  luas: double.tryParse(_luasController.text) ?? 0.0,
                  rekomendasi: _fertilizerRecommendation ?? '-',
                );
              }
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Dashboard()),
                (Route<dynamic> route) => false,
              );

              },
            ),

          ] else if (_showRecommendationInput)
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: 'Lihat Rekomendasi',
                    onPressed: _calculateRecommendation,
                  ),
        ],
      ),

            ),
          );
        }
      }


class SawahInputFields extends StatelessWidget {
  final TextEditingController gkgController;
  final TextEditingController luasController;

  const SawahInputFields({
    Key? key,
    required this.gkgController,
    required this.luasController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label GKG
        Text(
          'Gabah Kering Giling (GKG/ton)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: gkgController,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Label Luas
        Text(
          'Luas Sawah (m²)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: luasController,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
