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
          backgroundColor: primaryGreen, 
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
          backgroundColor: grey,
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
  String? _predictionResult; 
  String? _fertilizerRecommendation;
  bool _showRecommendationInput = false; 

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
      shape: const RoundedRectangleBorder( 
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green), 
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
                leading: const Icon(Icons.photo_library, color: Colors.green), 
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
      if (mounted) { 
        setState(() {
          _selectedImage = File(pickedFile.path);
          _predictionResult = null; 
          _fertilizerRecommendation = null; 
          _showRecommendationInput = false; 
          _luasController.clear(); 
          _gkgController.clear(); 
        });
      }
      
      _sendImageForPrediction();
    } else {
      
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
        _predictionResult = null; 
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
          const SnackBar(content: Text('Silakan lakukan prediksi gambar yang berhasil terlebih dahulu')), 
        );
      }
      return;
    }

    if (_gkgController.text.isEmpty || _luasController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi GKG dan Luas Sawah')), 
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

      
      final String recommendationResult = getUreaRecommendation(_predictionResult!, gkg, luasMeter);
      final location = await getCurrentLocation(); 

      await FirebaseService.uploadResultToFirebase(
        _predictionResult!, 
        location,
        gkg: gkg.toDouble(),
        luas: luasMeter,
        rekomendasi: recommendationResult,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _fertilizerRecommendation = recommendationResult; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _fertilizerRecommendation = 'Terjadi kesalahan: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text('Error menghitung rekomendasi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
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
        padding: const EdgeInsets.all(20), 
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
                  borderRadius: BorderRadius.circular(12), 
                ),
              ),
              const SizedBox(height: 16),
            ],

           
            if (_isLoading && _predictionResult == null)
              const Center(child: CircularProgressIndicator()) 
            else if (_predictionResult != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), 
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.green, size: 30), 
                      const SizedBox(width: 10), 
                      Expanded(
                        child: Text(
                          
                          'Klasifikasi Warna: \n $classificationDisplay',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16), 

           
            if (_fertilizerRecommendation != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), 
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture, color: Colors.blue, size: 30), 
                      const SizedBox(width: 10),
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

            const SizedBox(height: 24), 

           
            if (_showRecommendationInput)
              Column(
                children: [
                  SawahInputFields(
                    gkgController: _gkgController,
                    luasController: _luasController,
                  ),
                  const SizedBox(height: 20), 
                ],
              ),

           
            const SizedBox(height: 20), 
            if (_predictionResult != null && !_showRecommendationInput) ...[
              PrimaryButton(
                text: 'Lihat Rekomendasi Pemupukan',
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _showRecommendationInput = true;
                      _fertilizerRecommendation = null; 
                    });
                  }
                },
              ),
              const SizedBox(height: 10), 
              SecondaryButton(
                text: 'Selesai',
                onPressed: () async {
                 
                  if (_predictionResult != null && !_predictionResult!.startsWith('Terjadi kesalahan')) {
                    try {
                      final location = await getCurrentLocation();
                      await FirebaseService.uploadResultToFirebase(
                        _predictionResult!, 
                        location,
                        gkg: double.tryParse(_gkgController.text) ?? 0.0,
                        luas: double.tryParse(_luasController.text) ?? 0.0,
                        rekomendasi: _fertilizerRecommendation ?? '-', 
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
                  ? const Center(child: CircularProgressIndicator()) 
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
