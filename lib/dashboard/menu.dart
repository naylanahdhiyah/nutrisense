import 'package:flutter/material.dart';
// import 'package:nutrisense/pages/constant.dart'; // Jika ini digunakan, pastikan tidak dihapus
import 'package:nutrisense/pages/scan.dart'; 
import 'package:nutrisense/pages/histori.dart'; 

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 3, 
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        mainAxisSpacing: 16, 
        crossAxisSpacing: 8, 
        // childAspectRatio: 1.0,
        children: [
          _buildMenuItem(
            context,
            imagePath: 'assets/icons/card_scan.png', 
            // label: 'Scan Daun Padi', 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ScanPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            imagePath: 'assets/icons/card_history.png', 
            // label: 'Riwayat Scan', 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HistoriPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            imagePath: 'assets/icons/card_insight.png', 
            // label: 'Petunjuk Penggunaan', 
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => GuidePage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required String imagePath, 
    // required String label, 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // elevation: 4, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), 
        ),
        clipBehavior: Clip.antiAlias, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Expanded( 
              child: Padding(
                padding: const EdgeInsets.all(0.0), 
                child: Image.asset(
                  imagePath,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error); 
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
