import 'package:flutter/material.dart';
import 'package:nutrisense/services/auth.dart';
import 'package:nutrisense/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisense/pages/constant.dart';

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    User? user = await Auth().getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _logout(BuildContext context) async {
    await Auth().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/icons/profile.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.email ?? 'Email tidak tersedia',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  const Spacer(), // Membuat tombol ada di bawah
                  PrimaryButton(
                    text: 'Edit Profil',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fitur Edit Profil akan segera hadir!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)
                          ),
                          backgroundColor: Colors.black87, 
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'Logout',
                    onPressed: () => _logout(context),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
