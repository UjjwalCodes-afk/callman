import 'package:flutter/material.dart';
import 'dart:async';
import 'package:callman/Pages/Login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Use WidgetsBinding to ensure navigation occurs after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matches native splash background
      body: Center(
        child: Image.asset(
          'images/callman.png', // Same image as native splash
          width: 400,
          height: 400,
        ),
      ),
    );
  }
}
