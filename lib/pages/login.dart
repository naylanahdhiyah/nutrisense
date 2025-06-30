import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisense/pages/constant.dart';
import 'package:nutrisense/services/auth.dart';
import 'package:nutrisense/widget_tree.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Email dan kata sandi tidak boleh kosong.';
      });
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WidgetTree()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Pengguna dengan email ini tidak ditemukan. Silakan daftar.';
            break;
          case 'wrong-password':
            errorMessage = 'Kata sandi salah. Mohon periksa kembali.';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid. Pastikan email benar.';
            break;
          case 'user-disabled':
            errorMessage = 'Akun ini telah dinonaktifkan. Silakan hubungi dukungan.';
            break;
          case 'too-many-requests':
            errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti.';
            break;
          default:
            errorMessage = 'Terjadi kesalahan saat login: ${e.message}';
            break;
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Email dan kata sandi tidak boleh kosong.';
      });
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      setState(() {
        errorMessage = ''; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan login.'),
          backgroundColor: Colors.green, 
        ),
      );

      setState(() {
        isLogin = true; 
      });
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email ini sudah terdaftar. Silakan login atau gunakan email lain.';
            break;
          case 'weak-password':
            errorMessage = 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid. Pastikan email benar.';
            break;
          default:
            errorMessage = 'Terjadi kesalahan saat pendaftaran: ${e.message}';
            break;
        }
      });
    }
  }

  Widget _title() {
    return Text(
      'Mulai',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title[0].toUpperCase() + title.substring(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
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
      ],
    );
  }

  Widget _errorMessage() {
    if (errorMessage == '' || errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        errorMessage ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: primaryGreen),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Login',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: primaryGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/icons/cultivating.png',
                  height: 150,
                ),
                const SizedBox(height: 32),
                _title(),
                const SizedBox(height: 32),
                _entryField('email', _controllerEmail),
                _entryField('password', _controllerPassword, isPassword: true),
                _errorMessage(),
                _submitButton(),
                const SizedBox(height: 16),
                _loginOrRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}