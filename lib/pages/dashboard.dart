import 'package:flutter/material.dart';
import 'package:nutrisense/dashboard/maps.dart'; 
import 'package:nutrisense/dashboard/weather.dart'; 
import 'package:nutrisense/dashboard/header.dart'; 
import 'package:nutrisense/dashboard/menu.dart'; 

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: SingleChildScrollView( 
          physics: const ClampingScrollPhysics(), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            mainAxisSize: MainAxisSize.min, 
            children: [
              const DashboardHeader(),
              const SizedBox(height: 16), 
              const WeatherCard(),
              const SizedBox(height: 24), 

              // Bagian Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.headlineMedium
                ),
              ),
              const SizedBox(height: 8),
              const MenuSection(), 

              const SizedBox(height: 24), // Spasi antara Menu dan Peta Warna

              // Bagian Peta Warna
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Peta Warna',
                  style: Theme.of(context).textTheme.headlineMedium
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 250, 
                child: const Maps(), // Widget Maps Anda
              ),
              const SizedBox(height: 24), 
            ]
          ),
        ),
      ),
    );
  }
}

class MapsCard extends StatelessWidget {
  const MapsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Maps(), 
    );
  }
}
