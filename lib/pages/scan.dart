import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisense/pages/constant.dart'; 
import 'package:nutrisense/services/prediction.dart'; 
import 'package:nutrisense/services/firebase_service.dart'; 
import 'package:nutrisense/utils/location_util.dart'; 
import 'package:nutrisense/data/recommendation.dart';
import 'package:nutrisense/pages/dashboard.dart'; 

import 'package:nutrisense/utils/classification.dart'; 


class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen, // Pastikan primaryGreen didefinisikan di constant.dart
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: grey, // Pastikan grey didefinisikan di constant.dart
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}


class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _predictionResult; // Stores only the classification result (e.g., 'N23')
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
      shape: const RoundedRectangleBorder( // Tambahkan const
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green), // Tambahkan const
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
                leading: const Icon(Icons.photo_library, color: Colors.green), // Tambahkan const
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
      if (mounted) { // Pastikan widget masih mounted
        setState(() {
          _selectedImage = File(pickedFile.path);
          _predictionResult = null; // Reset prediction when a new image is picked
          _fertilizerRecommendation = null; // Reset recommendation
          _showRecommendationInput = false; // Hide input fields
          _luasController.clear(); // Clear input fields
          _gkgController.clear(); // Clear input fields
        });
      }
      // Automatically send for prediction after image is picked
      _sendImageForPrediction();
    } else {
      // Jika pengguna membatalkan pemilihan gambar, kembali ke Dashboard
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> _sendImageForPrediction() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')), // Tambahkan const
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _predictionResult = null; // Clear previous result
      });
    }

    try {
      final result = await PredictionService.sendImageForPrediction(_selectedImage!);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictionResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictionResult = 'Terjadi kesalahan: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text('Error prediksi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _calculateRecommendation() async {
    if (_predictionResult == null || _predictionResult!.startsWith('Terjadi kesalahan')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan lakukan prediksi gambar yang berhasil terlebih dahulu')), // Tambahkan const
        );
      }
      return;
    }

    if (_gkgController.text.isEmpty || _luasController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi GKG dan Luas Sawah')), // Tambahkan const
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double luasMeter = double.tryParse(_luasController.text) ?? 0.0;
      final int gkg = int.tryParse(_gkgController.text) ?? 0;

      // Pastikan _predictionResult adalah kode klasifikasi yang valid (misal: N23)
      // sebelum memanggil getUreaRecommendation
      final String recommendationResult = getUreaRecommendation(_predictionResult!, gkg, luasMeter);
      final location = await getCurrentLocation(); // Get location here

      await FirebaseService.uploadResultToFirebase(
        _predictionResult!, // Simpan kode klasifikasi asli
        location,
        gkg: gkg.toDouble(),
        luas: luasMeter,
        rekomendasi: recommendationResult, // Simpan rekomendasi yang sudah diformat
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _fertilizerRecommendation = recommendationResult; // Simpan rekomendasi yang sudah diformat
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _fertilizerRecommendation = 'Terjadi kesalahan: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar( // Tampilkan SnackBar untuk error
          SnackBar(content: Text('Error menghitung rekomendasi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan deskripsi klasifikasi warna menggunakan fungsi Anda
    final String classificationDisplay =
        _predictionResult != null && !_predictionResult!.startsWith('Terjadi kesalahan')
            ? getClassDescription(_predictionResult!)
            : (_predictionResult ?? 'Belum diklasifikasi');

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
        padding: const EdgeInsets.all(20), // Tambahkan const
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
                  borderRadius: BorderRadius.circular(12), // Tambahkan border radius
                ),
              ),
              const SizedBox(height: 16), // Tambahkan const
            ],

            // 1. Klasifikasi warna
            if (_isLoading && _predictionResult == null)
              const Center(child: CircularProgressIndicator()) // Tambahkan const
            else if (_predictionResult != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Tambahkan const
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.green, size: 30), // Tambahkan const
                      const SizedBox(width: 10), // Tambahkan const
                      Expanded(
                        child: Text(
                          // Gunakan classificationDisplay di sini
                          'Klasifikasi Warna: \n $classificationDisplay',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16), // Tambahkan const

            // 2. Rekomendasi (jika sudah dihitung)
            if (_fertilizerRecommendation != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Tambahkan const
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture, color: Colors.blue, size: 30), // Tambahkan const
                      const SizedBox(width: 10), // Tambahkan const
                      Expanded(
                        child: Text(
                          'Rekomendasi Pemupukan: $_fertilizerRecommendation',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24), // Tambahkan const

            // 3. Input Field
            if (_showRecommendationInput)
              Column(
                children: [
                  SawahInputFields(
                    gkgController: _gkgController,
                    luasController: _luasController,
                  ),
                  const SizedBox(height: 20), // Tambahkan const
                ],
              ),

            // 4. Tombol di paling bawah
            const SizedBox(height: 20), // Tambahkan const
            if (_predictionResult != null && !_showRecommendationInput) ...[
              PrimaryButton(
                text: 'Lihat Rekomendasi Pemupukan',
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _showRecommendationInput = true;
                      _fertilizerRecommendation = null; // Reset rekomendasi saat menampilkan input
                    });
                  }
                },
              ),
              const SizedBox(height: 10), // Tambahkan const
              SecondaryButton(
                text: 'Selesai',
                onPressed: () async {
                  // Pastikan _predictionResult bukan null dan bukan pesan error
                  if (_predictionResult != null && !_predictionResult!.startsWith('Terjadi kesalahan')) {
                    try {
                      final location = await getCurrentLocation();
                      await FirebaseService.uploadResultToFirebase(
                        _predictionResult!, // Simpan kode klasifikasi asli
                        location,
                        gkg: double.tryParse(_gkgController.text) ?? 0.0,
                        luas: double.tryParse(_luasController.text) ?? 0.0,
                        rekomendasi: _fertilizerRecommendation ?? '-', // Gunakan rekomendasi yang sudah dihitung
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data berhasil disimpan!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan data: ${e.toString()}')),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tidak ada hasil prediksi yang valid untuk disimpan.')),
                      );
                    }
                  }
                  // Selalu navigasi kembali ke Dashboard setelah selesai
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Dashboard()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ] else if (_showRecommendationInput)
              _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Tambahkan const
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
        const SizedBox(height: 6), // Tambahkan const
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Tambahkan const
          ),
        ),
        const SizedBox(height: 16), // Tambahkan const

        // Label Luas
        Text(
          'Luas Sawah (m²)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6), // Tambahkan const
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Tambahkan const
          ),
        ),
      ],
    );
  }
}
