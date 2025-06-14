import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostCallDetailsCard extends StatefulWidget {
  const PostCallDetailsCard({Key? key}) : super(key: key);

  @override
  _PostCallDetailsCardState createState() => _PostCallDetailsCardState();
}

class _PostCallDetailsCardState extends State<PostCallDetailsCard> {
  final TextEditingController _reminderController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  String? _callId;
  String? _bearerToken;

  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _log("Initializing PostCallDetailsCard...");
    _loadCallDetails();
  }

  void _log(String message) {
    setState(() {
      _logs.add("${DateFormat('HH:mm:ss').format(DateTime.now())} - $message");
    });
  }

  Future<void> _loadCallDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _callId = prefs.getString('callId');
        _bearerToken = prefs.getString('token');
      });
      if (_callId == null || _bearerToken == null) {
        _log("Call ID or Token not found in preferences!");
      } else {
        _log("Call details loaded successfully.");
      }
    } catch (e) {
      _log("Error loading call details: $e");
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            _selectedDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            _reminderController.text =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!);
          });
          _log("Selected date and time: $_selectedDate");
        }
      }
    } catch (e) {
      _log("Error selecting date and time: $e");
    }
  }

  Future<void> _saveDetails() async {
    if (_callId == null || _bearerToken == null) {
      _showMessage("Call ID or Bearer Token not found!");
      return;
    }

    final String reminder = _reminderController.text.trim();
    final String remarks = _remarksController.text.trim();

    if (reminder.isEmpty || remarks.isEmpty) {
      _showMessage("Both fields are required!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = 'https://api.callman.in/api/user/call/$_callId';
      _log("API URL: $apiUrl");

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reminder': reminder,
          'remarks': remarks,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showMessage(responseData['message'] ?? 'Details saved successfully!');
        _log("Details saved successfully: $responseData");
        Navigator.of(context).pop();
      } else {
        final responseData = jsonDecode(response.body);
        _showMessage(responseData['message'] ?? 'Failed to save details.');
        _log("Error saving details: $responseData");
      }
    } catch (e) {
      _log("Exception while saving details: $e");
      _showMessage('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _log(message);
  }

  @override
  Widget build(BuildContext context) {
     return Center(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.75, // Reduced width
    padding: const EdgeInsets.all(16), // Smaller padding
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16), // Slightly smaller radius
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.black54, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reminderController,
          readOnly: true,
          onTap: () => _selectDateTime(context),
          decoration: const InputDecoration(
            labelText: "Set Reminder",
            hintText: "Pick a date and time",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _remarksController,
          decoration: const InputDecoration(
            labelText: "Add Remarks",
            hintText: "Enter remarks",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2C49),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'SAVE DETAILS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 16),
      ],
    ),
  ),
);

  }
}
