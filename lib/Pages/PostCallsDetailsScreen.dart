// import 'dart:convert';
// import 'package:callman/reminder_channel.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:callman/reminder_channel.dart';

// class PostCallDetailsCard extends StatefulWidget {
//   const PostCallDetailsCard({Key? key}) : super(key: key);

//   @override
//   _PostCallDetailsCardState createState() => _PostCallDetailsCardState();
// }

// class _PostCallDetailsCardState extends State<PostCallDetailsCard> {
//   final TextEditingController _reminderController = TextEditingController();
//   final TextEditingController _remarksController = TextEditingController();

//   DateTime? _selectedDate;
//   bool _isLoading = false;

//   String? _callId;
//   String? _bearerToken;

//   List<String> _logs = [];

//   @override
//   void initState() {
//     super.initState();
//     _log("Initializing PostCallDetailsCard...");
//     _loadCallDetails();
//   }

//   void _log(String message) {
//     setState(() {
//       _logs.add("${DateFormat('HH:mm:ss').format(DateTime.now())} - $message");
//     });
//   }

//   Future<void> _loadCallDetails() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _callId = prefs.getString('callId');
//         _bearerToken = prefs.getString('token');
//       });
//       if (_callId == null || _bearerToken == null) {
//         _log("Call ID or Token not found in preferences!");
//       } else {
//         _log("Call details loaded successfully.");
//       }
//     } catch (e) {
//       _log("Error loading call details: $e");
//     }
//   }

//   Future<void> _selectDateTime(BuildContext context) async {
//     try {
//       final DateTime? pickedDate = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2101),
//       );
//       if (pickedDate != null) {
//         final TimeOfDay? pickedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.now(),
//         );
//         if (pickedTime != null) {
//           setState(() {
//             _selectedDate = DateTime(
//               pickedDate.year,
//               pickedDate.month,
//               pickedDate.day,
//               pickedTime.hour,
//               pickedTime.minute,
//             );
//             _reminderController.text =
//                 DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!);
//           });
//           _log("Selected date and time: $_selectedDate");
//         }
//       }
//     } catch (e) {
//       _log("Error selecting date and time: $e");
//     }
//   }

// Future<void> _saveDetails() async {
//   _log("🔍 Entered _saveDetails()");

//   if (_callId == null || _bearerToken == null) {
//     _log("❌ Missing callId or bearerToken");
//     _showMessage("Call ID or Bearer Token not found!");
//     return;
//   }

//   final String reminder = _reminderController.text.trim();
//   final String remarks = _remarksController.text.trim();

//   _log("📝 Reminder: $reminder");
//   _log("📝 Remarks: $remarks");

//   if (reminder.isEmpty || remarks.isEmpty) {
//     _log("⚠️ Fields are empty");
//     _showMessage("Both fields are required!");
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final String apiUrl = 'https://api.callman.in/api/user/call/$_callId';
//     _log("🌐 PUT Request to: $apiUrl");

//     final requestBody = jsonEncode({
//       'reminder': reminder,
//       'remarks': remarks,
//     });

//     _log("📦 Request Body: $requestBody");

//     final response = await http.put(
//       Uri.parse(apiUrl),
//       headers: {
//         'Authorization': 'Bearer $_bearerToken',
//         'Content-Type': 'application/json',
//       },
//       body: requestBody,
//     );

//     _log("📬 Response Status Code: ${response.statusCode}");
//     _log("📬 Response Body: ${response.body}");

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       _log("✅ API success: $responseData");

//       if (_selectedDate != null) {
//         _log("⏰ Scheduling native reminder at: ${_selectedDate!.millisecondsSinceEpoch}");

//         try {
//           await NativeReminder.scheduleReminder(
//             id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//             title: "Reminder",
//             body: remarks,
//             epochMillis: _selectedDate!.millisecondsSinceEpoch,
//           );
//           _log("✅ Native reminder scheduled.");
//         } catch (e) {
//           _log("❌ Error scheduling native reminder: $e");
//         }
//       }

//       _showMessage(responseData['message'] ?? 'Details saved successfully!');
//       Navigator.of(context).pop();
//     } else {
//       final responseData = jsonDecode(response.body);
//       _log("❌ API error: $responseData");
//       _showMessage(responseData['message'] ?? 'Failed to save details.');
//     }
//   } catch (e) {
//     _log("❌ Exception caught in _saveDetails(): $e");
//     _showMessage('An error occurred. Please try again.');
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//     _log("🔚 Exiting _saveDetails()");
//   }
// }

//   Future<void> _setSystemAlarm() async {
//   if (_selectedDate == null) {
//     _showMessage('Pick a date & time first.');
//     return;
//   }
//   try {
//     await NativeReminder.setSystemAlarm(
//       hour: _selectedDate!.hour,
//       minute: _selectedDate!.minute,
//       message: _remarksController.text.isNotEmpty
//           ? _remarksController.text
//           : 'Reminder',
//       skipUi: false,           // set to true if you want to bypass the Clock UI
//     );
//     _log('✅ System alarm set.');
//     _showMessage('System alarm scheduled!');
//   } catch (e) {
//     _log('❌ Failed to set system alarm: $e');
//     _showMessage('Could not set system alarm.');
//   }
// }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//     _log(message);
//   }

//   @override
//   Widget build(BuildContext context) {
//      return Center(
//   child: Container(
//     width: MediaQuery.of(context).size.width * 0.75, // Reduced width
//     padding: const EdgeInsets.all(16), // Smaller padding
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16), // Slightly smaller radius
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.2),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: const Icon(Icons.close, color: Colors.black54, size: 20),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _reminderController,
//           readOnly: true,
//           onTap: () => _selectDateTime(context),
//           decoration: const InputDecoration(
//             labelText: "Set Reminder",
//             hintText: "Pick a date and time",
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           ),
//           style: const TextStyle(fontSize: 13),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _remarksController,
//           decoration: const InputDecoration(
//             labelText: "Add Remarks",
//             hintText: "Enter remarks",
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           ),
//           style: const TextStyle(fontSize: 13),
//         ),
//         const SizedBox(height: 20),
//         _isLoading
//             ? const CircularProgressIndicator()
//             : SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveDetails,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF0B2C49),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text(
//                     'SAVE DETAILS',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//         const SizedBox(height: 16),
//         OutlinedButton.icon(
//   icon: const Icon(Icons.alarm, size: 16),
//   label: const Text(
//     'SET SYSTEM ALARM',
//     style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//   ),
//   onPressed: _setSystemAlarm,
// ),

//       ],
//     ),
//   ),
// );

//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callman/reminder_channel.dart';

class PostCallDetailsCard extends StatefulWidget {
  const PostCallDetailsCard({Key? key}) : super(key: key);

  @override
  State<PostCallDetailsCard> createState() => _PostCallDetailsCardState();
}

class _PostCallDetailsCardState extends State<PostCallDetailsCard> {
  final _remarksController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  String? _callId;
  String? _bearerToken;

  @override
  void initState() {
    super.initState();
    _loadCallDetails();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _log(String msg) {
    debugPrint(msg);
  }

  Future<void> _loadCallDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callId = prefs.getString('callId');
      _bearerToken = prefs.getString('token');
    });
    _log("📥 Loaded callId=$_callId & token=$_bearerToken");
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
      );
      if (time != null) {
        setState(() {
          _selectedDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveDetails() async {
    if (_callId == null || _bearerToken == null) {
      _showMessage("Call ID or Bearer Token not found!");
      return;
    }

    final remarks = _remarksController.text.trim();
    final reminder = _selectedDate?.toUtc().toIso8601String() ?? '';

    if (remarks.isEmpty || reminder.isEmpty) {
      _showMessage("Please enter remarks and select a date.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('https://api.callman.in/api/user/call/$_callId'),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reminder': reminder, 'remarks': remarks}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final reminders = prefs.getStringList('call_reminders') ?? [];
        reminders.add(jsonEncode({
          'callId': _callId,
          'remarks': remarks,
          'reminderTime': _selectedDate!.millisecondsSinceEpoch,
          'phoneNumber': '', // You might want to store the number too
        }));
        await prefs.setStringList('call_reminders', reminders);
            debugPrint('✅ Saved reminder to SharedPreferences:');
      debugPrint('Call ID: $_callId');
      debugPrint('Remarks: $remarks');
      debugPrint('Time: ${_selectedDate!.toIso8601String()}');
      debugPrint('All stored reminders: ${prefs.getStringList('call_reminders')}');
        await NativeReminder.scheduleReminder(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Reminder",
          body: remarks,
          epochMillis: _selectedDate!.millisecondsSinceEpoch,
        );
        _showMessage("Reminder saved and scheduled!");
        Navigator.of(context).pop();
      } else {
        final res = jsonDecode(response.body);
        _showMessage(res['message'] ?? 'Failed to save details.');
      }
    } catch (e) {
      _showMessage("Something went wrong.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setSystemAlarm() async {
    if (_selectedDate == null || _remarksController.text.trim().isEmpty) {
      _showMessage("Select a time and enter a message.");
      return;
    }
    try {
      await NativeReminder.setSystemAlarm(
        hour: _selectedDate!.hour,
        minute: _selectedDate!.minute,
        message: _remarksController.text.trim(),
        skipUi: false,
      );
      _showMessage("System alarm set!");
    } catch (e) {
      _showMessage("Failed to set system alarm.");
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeText = _selectedDate != null
        ? DateFormat.yMMMEd().add_jm().format(_selectedDate!)
        : 'Select date & time';

    return Center(
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                'Post Call Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today),
                label: Text(dateTimeText),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveDetails,
                icon: const Icon(Icons.check_circle),
                label: _isLoading
                    ? const Text('Saving...')
                    : const Text('Save & Set App Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _selectedDate != null ? _setSystemAlarm : null,
                icon: const Icon(Icons.schedule),
                label: const Text('Set System Alarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
