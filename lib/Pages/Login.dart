


import 'package:callman/Pages/DoctorHome.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? userName; // Variable to store the user's name

  Future<void> login() async {
  final url = Uri.parse('https://api.callman.in/api/user/login');
  final body = {
    "email": emailController.text.trim(),
    "password": passwordController.text.trim(),
  };

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Extract user details
      final user = data['user'];
      final token = user['token'];
      final name = user['name'] ?? 'Guest';
      final email = user['email'] ?? '';
      final mobile = user['mobile'].toString();
      final companyName = user['companyName'] ?? '';
      final domain = user['domain'] ?? '';
      final role = user['role'] ?? '';

      // Restrict login for superadmin
      if (role.toLowerCase() == 'superadmin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Superadmin role cannot log in.")),
        );
        return; // Stop further execution
      }

      // Save data locally using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('userMobile', mobile);
      await prefs.setString('companyName', companyName);
      await prefs.setString('domain', domain);
      await prefs.setString('userRole', role);

      // Optional: print token for debugging
      print("✅ Token stored: $token");

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful: ${data['message']}")),
      );

      // Navigate to the home screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorHomeScreen(
            email: email,
            userName: name,
          ),
        ),
      );
    } else {
      // Login failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data['message']}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color.fromARGB(255, 0, 1, 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: "Sign In / Log In"
                  Row(
                    children: [
                      Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Good to see you back!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email TextFormField
                  TextFormField(
                    controller: emailController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: darkBlue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: darkBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your email";
                      }
                      final emailRegex =
                          RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                      if (!emailRegex.hasMatch(value.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password TextFormField
                  TextFormField(
                    controller: passwordController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: darkBlue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: darkBlue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: darkBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Log in",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(child: Text("or")),

                  const SizedBox(height: 16),

                  // Sign Up link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.poppins(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: GoogleFonts.poppins(
                              color: darkBlue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to sign-up screen
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
