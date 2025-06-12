import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:callman/Pages/Login.dart';
import 'package:callman/Pages/DoctorHome.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      checkAuthStatus();
    });
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Get user data (optional, or use placeholders)
      final userName = prefs.getString('userName') ?? '';
      final email = prefs.getString('userEmail') ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorHomeScreen(
            userName: userName,
            email: email,
          ),
        ),
      );
    } else {
      goToLogin();
    }
  }

  void goToLogin() {
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'images/callman.png',
          width: 400,
          height: 400,
        ),
      ),
    );
  }
}