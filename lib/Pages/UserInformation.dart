import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String phoneNumber;

  const UserProfilePage({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.phoneNumber,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _handleSubmit() {
    // Replace with your own logic to upload/save data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _pickedImage != null
        ? FileImage(_pickedImage!)
        : NetworkImage(widget.avatarUrl) as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar with tap to pick
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.grey[200],
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera_alt, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Username Field
              TextFormField(
                initialValue: widget.username,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                initialValue: widget.phoneNumber,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 🔲 Black background
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // ⚪ White text
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
