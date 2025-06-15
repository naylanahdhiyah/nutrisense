import 'package:nutrisense/services/auth.dart';
import 'package:nutrisense/pages/dashboard.dart';
// import 'package:nutrisense/pages/homepage.dart';
import 'package:nutrisense/pages/login.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, 
      builder: (context, snapshot) {
        if (snapshot.hasData){
          return Dashboard();
        } else {
          return const LoginPage();
          }
      },
    );
  }
}
