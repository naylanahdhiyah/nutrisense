import 'package:flutter/material.dart';
import 'package:nutrisense/pages/login.dart';
// import 'package:nutrisense/widget_tree.dart';
import 'constant.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    Image.asset(
                      'assets/icons/cultivating.png',
                      height: 250,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Selamat datang',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kenali kebutuhan nutrisi tanamanmu\n dengan NutriSense',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

     
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
         
          child: PrimaryButton( 
            text: 'Mulai', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
