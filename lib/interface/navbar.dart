import 'package:flutter/material.dart';
import 'package:nutrisense/pages/constant.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 0
                ? 'assets/icons/Home.png'
                : 'assets/icons/Home_Off.png',
            width: 20,
            height: 20,
          ),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 1
                ? 'assets/icons/Scan.png'
                : 'assets/icons/Scan_Off.png',
            width: 20,
            height: 20,
          ),
          label: "Scan Tanaman",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 2
                ? 'assets/icons/History.png'
                : 'assets/icons/History_Off.png',
            width: 20,
            height: 20,
          ),
          label: "Histori",
        ),
      ],
      currentIndex: currentIndex,
      unselectedFontSize: 12,
      selectedFontSize: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      selectedItemColor: primaryGreen,
      onTap: onTap,
    );
  }
}
