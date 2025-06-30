import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:nutrisense/pages/constant.dart';
import 'package:nutrisense/pages/splash.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600), //font dashboard
          displaySmall: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500),
          headlineLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), //judul menu
          headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight:FontWeight.bold),
          bodyMedium: GoogleFonts.poppins(fontSize: 14,fontWeight: FontWeight.w700),
          bodySmall: GoogleFonts.poppins(fontSize: 14, fontWeight:FontWeight.w500),
          labelLarge: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
          labelMedium: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700),
          labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
        )
      ),
    
      home: const SplashScreen(),
    );
  }
}
