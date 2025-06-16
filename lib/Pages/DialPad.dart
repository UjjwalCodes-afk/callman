// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class DialPadScreen extends StatefulWidget {
//   final String? userName;
//   final String? email;

//   const DialPadScreen({Key? key, this.userName, this.email}) : super(key: key);

//   @override
//   State<DialPadScreen> createState() => _DialPadScreenState();
// }

// class _DialPadScreenState extends State<DialPadScreen> {
//   String phoneNumber = "";

//   void _addDigit(String digit) {
//     setState(() {
//       phoneNumber += digit;
//     });
//   }

//   void _deleteDigit() {
//     if (phoneNumber.isNotEmpty) {
//       setState(() {
//         phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
//       });
//     }
//   }

//   Future<void> _sendCallData() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final String? token = prefs.getString('token');

//   if (token == null) {
//     debugPrint("No token found!");
//     return;
//   }

//   final now = DateTime.now();
//   // final end = now.add(const Duration(minutes: 30));

//   final url = Uri.parse("https://api.callman.in/api/user/call");

//   final body = {
//     "callerName": widget.userName ?? "Guest",
//     "callerNumber": phoneNumber,
//     "callType": 0,
//     "callStartDate": now.toUtc().toIso8601String(),
//     // "callEndDate": end.toUtc().toIso8601String(),
//   };

//   try {
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token", // Add token here
//       },
//       body: jsonEncode(body),
//     );

//     if (response.statusCode != 200) {
//       debugPrint("Failed to send call data: ${response.statusCode}");
//     }
//   } catch (e) {
//     debugPrint("Error sending call data: $e");
//   }
// }

//   Future<void> _makeCall() async {
//     var status = await Permission.phone.status;
//     if (!status.isGranted) {
//       status = await Permission.phone.request();
//     }

//     if (status.isGranted && phoneNumber.isNotEmpty) {
//       _showCallingAlert();
//       await _sendCallData();
//       await FlutterPhoneDirectCaller.callNumber(phoneNumber);
//     }
//   }

//   void _showCallingAlert() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black,
//         content: Text(
//           'Calling as ${widget.userName ?? "Guest"}',
//           style: const TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ),
//     );

//     Future.delayed(const Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }

//   Widget _buildDialButton(String label) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(40),
//         splashColor: Colors.white24,
//         highlightColor: Colors.white10,
//         onTap: () {
//           HapticFeedback.selectionClick();
//           _addDigit(label);
//         },
//         child: Center(
//           child: SizedBox(
//             width: 70,
//             height: 70,
//             child: Center(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 34,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//       ),
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Text(
//               phoneNumber,
//               style: const TextStyle(fontSize: 30, color: Colors.white),
//             ),
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 itemCount: buttons.length,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
//                   childAspectRatio: 1.0,
//                 ),
//                 itemBuilder: (_, index) {
//                   return _buildDialButton(buttons[index]);
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FloatingActionButton(
//                   backgroundColor: Colors.green,
//                   onPressed: _makeCall,
//                   child: const Icon(Icons.call, color: Colors.white),
//                 ),
//                 const SizedBox(width: 30),
//                 GestureDetector(
//                   onTap: _deleteDigit,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade800,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.backspace_outlined,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:phone_state/phone_state.dart';

// class DialPadScreen extends StatefulWidget {
//   final String? userName;
//   final String? email;

//   const DialPadScreen({Key? key, this.userName, this.email}) : super(key: key);

//   @override
//   State<DialPadScreen> createState() => _DialPadScreenState();
// }

// class _DialPadScreenState extends State<DialPadScreen> {
//   String phoneNumber = "";
//   String? _callId; // To store call ID returned from API
//   StreamSubscription<PhoneState>? _phoneStateSubscription;


//   @override
//   void initState() {
//     super.initState();
//     _listenToPhoneState();
//   }

//   @override
//   void dispose() {
//     _phoneStateSubscription?.cancel();
//     super.dispose();
//   }

//   void _listenToPhoneState() async {
//   var status = await Permission.phone.status;
//   if (!status.isGranted) {
//     status = await Permission.phone.request();
//   }
//   if (!status.isGranted) return;

//   _phoneStateSubscription = PhoneState.stream.listen((PhoneState event) {
//   debugPrint("Phone state changed: ${event.status}");
//   if (event.status == PhoneStateStatus.CALL_ENDED) {
//     _sendCallEndData();
//   }
// }) ;

// }


//   void _addDigit(String digit) {
//     setState(() {
//       phoneNumber += digit;
//     });
//   }

//   void _deleteDigit() {
//     if (phoneNumber.isNotEmpty) {
//       setState(() {
//         phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
//       });
//     }
//   }

//   Future<void> _sendCallData() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('token');

//     if (token == null) {
//       debugPrint("No token found!");
//       return;
//     }

//     final now = DateTime.now();

//     final url = Uri.parse("https://api.callman.in/api/user/call");

//     final body = {
//       "callerName": widget.userName ?? "Guest",
//       "callerNumber": phoneNumber,
//       "callType": 0,
//       "callStartDate": now.toUtc().toIso8601String(),
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _callId = data['call']['_id']; // Save callId for later update
//         });
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('callId', _callId!);

//   debugPrint("Call started with id: $_callId");
//         debugPrint("Call started with id: $_callId");
//       } else {
//         debugPrint("Failed to send call data: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error sending call data: $e");
//     }
//   }

//     Future<void> _sendCallEndData() async {
//   if (_callId == null) {
//     debugPrint("No callId to update.");
//     return;
//   }

//   final prefs = await SharedPreferences.getInstance();
//   final String? token = prefs.getString('token');

//   if (token == null) {
//     debugPrint("No token found!");
//     return;
//   }

//   final now = DateTime.now();
//   final url = Uri.parse("https://api.callman.in/api/user/call/$_callId");
//   final body = {"callEndDate": now.toUtc().toIso8601String()};

//   try {
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200) {
//       debugPrint("Call ended and updated successfully.");

//       // Move _callId from upcoming to past list
//       final pastCallIdsJson = prefs.getString('pastCallIds') ?? '[]';
//       List<String> pastCallIdsList = [];
//       try {
//         final decoded = jsonDecode(pastCallIdsJson);
//         if (decoded is List) pastCallIdsList = List<String>.from(decoded);
//       } catch (_) {}

//       if (!pastCallIdsList.contains(_callId)) {
//         pastCallIdsList.add(_callId!);
//       }

//       await prefs.setString('pastCallIds', jsonEncode(pastCallIdsList));
//       await prefs.remove('callId'); // Remove current callId since it ended

//       setState(() {
//         _callId = null;
//       });
//     } else {
//       debugPrint("Failed to update call end: ${response.statusCode}");
//     }
//   } catch (e) {
//     debugPrint("Error updating call end data: $e");
//   }
// }


//   Future<void> _makeCall() async {
//     var status = await Permission.phone.status;
//     if (!status.isGranted) {
//       status = await Permission.phone.request();
//     }

//     if (status.isGranted && phoneNumber.isNotEmpty) {
//       _showCallingAlert();
//       await _sendCallData();
//       await FlutterPhoneDirectCaller.callNumber(phoneNumber);
//     }
//   }

//   void _showCallingAlert() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black,
//         content: Text(
//           'Calling as ${widget.userName ?? "Guest"}',
//           style: const TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ),
//     );

//     Future.delayed(const Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }

//   Widget _buildDialButton(String label) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(40),
//         splashColor: Colors.white24,
//         highlightColor: Colors.white10,
//         onTap: () {
//           HapticFeedback.selectionClick();
//           _addDigit(label);
//         },
//         child: Center(
//           child: SizedBox(
//             width: 70,
//             height: 70,
//             child: Center(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 34,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//       ),
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Text(
//               phoneNumber,
//               style: const TextStyle(fontSize: 30, color: Colors.white),
//             ),
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 itemCount: buttons.length,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
//                   childAspectRatio: 1.0,
//                 ),
//                 itemBuilder: (_, index) {
//                   return _buildDialButton(buttons[index]);
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FloatingActionButton(
//                   backgroundColor: Colors.green,
//                   onPressed: _makeCall,
//                   child: const Icon(Icons.call, color: Colors.white),
//                 ),
//                 const SizedBox(width: 30),
//                 GestureDetector(
//                   onTap: _deleteDigit,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade800,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.backspace_outlined,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'package:callman/Pages/PostCallsDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';
import 'package:android_intent_plus/android_intent.dart';
// import 'package:contacts_service/contacts_service.dart';


import 'Interaction.dart';
// import 'PostCallsDetailsScreen.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';



class DialPadScreen extends StatefulWidget {
  final String? userName;
  final String? email;

  const DialPadScreen({Key? key, this.userName, this.email}) : super(key: key);

  @override
  State<DialPadScreen> createState() => _DialPadScreenState();
}

class _DialPadScreenState extends State<DialPadScreen> {
  bool _callDataSent = false; // ✅ Prevent duplicate sendCallData
  String phoneNumber = "";
  String? _callId;
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  bool _callStarted = false;
  DateTime? _callConnectedTime;
  bool _recordCall = false;
  String? _recordedFilePath; // 🔹 to save recorded file path

  static const overlayChannel = MethodChannel('overlay_channel');

Future<void> showOverlay(String name, String number) async {
  try {
    if (name.trim().isEmpty || number.trim().isEmpty) {
      debugPrint("❌ Overlay not shown – Missing name or number");
      return;
    }

    final normalizedNumber = normalizeNumber(number);
    debugPrint("📲 Sending to Overlay → Name: $name | Number: $normalizedNumber");

    await overlayChannel.invokeMethod('showOverlay', {
      'callerName': name,
      'callerNumber': normalizedNumber,
    });
  } on PlatformException catch (e) {
    debugPrint("Failed to show overlay: '${e.message}'");
  }
}




Future<void> checkOverlayPermission() async {
  if (!await Permission.systemAlertWindow.isGranted) {
    final intent = AndroidIntent(
      action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
      data: 'package:com.example.callman', // ✅ FIXED
    );
    await intent.launch();
  }
}
Future<String?> _getNameFromCallLog(String targetNumber) async {
  final Iterable<CallLogEntry> entries = await CallLog.get();
  final normalizedTarget = normalizeNumber(targetNumber);

  for (final entry in entries) {
    if (entry.number != null && normalizeNumber(entry.number!) == normalizedTarget) {
      final name = entry.name;
      if (name != null && name.trim().isNotEmpty) {
        return name;
      }
    }
  }

  return null;
}

  


  // int callDuration = DateTime.now().difference(_callConnectedTime!).inSeconds;
  
Future<void> _showInteractionPopupAndCall() async {
  if (phoneNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a phone number")),
    );
    return;
  }

  debugPrint("Dialing number: $phoneNumber");

  final interactionData = await _fetchLastInteraction(phoneNumber);
  final callLogName = await _getNameFromCallLog(phoneNumber);
  final contactName = await getContactNameByNumber(phoneNumber);
  final displayName = callLogName ?? contactName ?? "Guest";

  if (mounted) {
  debugPrint("✅ Showing overlay with name: $displayName, number: $phoneNumber");
  await showOverlay(displayName, phoneNumber);
  await _makeCall();
}


  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      final screenWidth = MediaQuery.of(context).size.width;
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  width: screenWidth,
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InteractionScreen(data: interactionData ?? {}),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (mounted) {
    await showOverlay(displayName, phoneNumber);
    await _makeCall();
  }
}




Future<List<String>> _getLastCallDetails() async {
  final status = await Permission.phone.request();
  if (!status.isGranted) return ["Unknown", "Unknown"];

  final Iterable<CallLogEntry> entries = await CallLog.get();

  // 🔍 Get most recent outgoing call
  CallLogEntry? lastOutgoing = entries.firstWhere(
    (entry) => entry.callType == CallType.outgoing && entry.number != null,
    orElse: () => CallLogEntry.fromMap({}),
  );

  if (lastOutgoing.number == null) {
    return ["Unknown", "Unknown"];
  }

  final number = lastOutgoing.number!;
  final name = await getContactNameByNumber(number) ?? "Unknown";

  return [name, number];
}


void debugPrintContacts() async {
  final contacts = await FlutterContacts.getContacts(withProperties: true);
  for (var c in contacts) {
    for (var p in c.phones) {
      print("${c.displayName} → ${p.number}");
    }
  }
}

String normalizeNumber(String number) {
  number = number.replaceAll(RegExp(r'\D'), ''); // remove non-digits
  if (number.length > 10) {
    return number.substring(number.length - 10); // keep last 10 digits
  }
  return number;
}


Future<void> _requestContactPermission() async {
  final isGranted = await FlutterContacts.requestPermission();
  if (!isGranted) {
    debugPrint("Contact permission denied!");
  }
}



Future<Map<String, dynamic>?> _fetchLastInteraction(String callerNumber) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print(token);

  if (token == null) {
    debugPrint("No token found!");
    return null;
  }

  final url = Uri.parse("https://api.callman.in/api/user/calls/last-interaction");

  final body = {"callerNumber": callerNumber};
  debugPrint("Request payload: $body");
  
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      
      body: jsonEncode(body),
    );
    debugPrint("Request payload: $body");

    debugPrint("Raw Response Body: ${response.body}");
    debugPrint("Request Headers: ${response.request?.headers}");
debugPrint("Request URL: ${response.request?.url}");
debugPrint("Request Body: $body");



    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Interaction fetched successfully: $data");
      return data;
    } else {
      debugPrint("Failed to fetch interaction: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error fetching interaction: $e");
  }

  return null;
}







@override
void initState() {
  super.initState();
  checkOverlayPermission();
  debugPrintContacts();
  _requestContactPermission();
  _askRuntimePermissions();
  _listenToPhoneState();
  
}


Future<String?> getContactNameByNumber(String number) async {
  final hasPermission = await FlutterContacts.requestPermission();
  if (!hasPermission) return null;

  final contacts = await FlutterContacts.getContacts(withProperties: true);
  final inputNumber = normalizeNumber(number);

  for (final contact in contacts) {
    for (final phone in contact.phones) {
      final stored = normalizeNumber(phone.number);
      if (stored == inputNumber) {
        return contact.displayName;
      }
    }
  }

  return null;
}



Future<void> _askRuntimePermissions() async {
  final statuses = await [
    Permission.phone,
    Permission.microphone,
    Permission.contacts,           // ⬅️ Needed for caller name
    Permission.phone,           // ⬅️ Needed to fetch call duration & logs
    Permission.storage,
    Permission.manageExternalStorage,
    Permission.systemAlertWindow,  // ⬅️ Overlay permission
  ].request();

  if (statuses[Permission.microphone]?.isDenied == true ||
      statuses[Permission.storage]?.isDenied == true) {
    debugPrint('🔴 Mic / Storage permission denied – recording will not work');
  }

  if (statuses[Permission.systemAlertWindow]?.isDenied == true) {
    debugPrint('🔴 Overlay permission is required to show floating views.');
    final intent = AndroidIntent(
      action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
      data: 'package:com.example.callman',
    );
    await intent.launch();
  }
}

  static const platform = MethodChannel('com.yourapp.call_recorder');

Future<void> startRecording() async {
  try {
    await platform.invokeMethod('startRecording');
  } on PlatformException catch (e) {
    debugPrint("Failed to start recording: '${e.message}'.");
  }
}

Future<String?> stopRecording() async {
  try {
    final path = await platform.invokeMethod<String>('stopRecording');
    debugPrint('Recording stopped.');
    return path;
  } on PlatformException catch (e) {
    debugPrint("Failed to stop recording: '${e.message}'.");
    return null;
  }
}




Future<int?> getCallDuration(String phoneNumber) async {
  final Iterable<CallLogEntry> entries = await CallLog.get();

  CallLogEntry? latestMatch;

  for (final entry in entries) {
    if (entry.number != null &&
        entry.number!.contains(phoneNumber) &&
        (entry.callType == CallType.outgoing || entry.callType == CallType.incoming)) {
      if (latestMatch == null || entry.timestamp! > latestMatch.timestamp!) {
        latestMatch = entry;
      }
    }
  }

  return latestMatch?.duration;
}





  @override
  void dispose() {
    _phoneStateSubscription?.cancel();
    super.dispose();
  }

  void _listenToPhoneState() async {
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
  }

  if (!status.isGranted) return;

  _phoneStateSubscription = PhoneState.stream.listen((PhoneState event) async {
    debugPrint("Phone state changed: ${event.status}");

    if (event.status == PhoneStateStatus.CALL_STARTED && !_callStarted) {
      _callStarted = true;
      _callConnectedTime = DateTime.now();
      await _sendCallData();
    }

    if (event.status == PhoneStateStatus.CALL_ENDED && _callStarted) {
      if (_recordCall) {
        _recordedFilePath = await stopRecording(); // Capture file path
        debugPrint('🎙 Recording saved at $_recordedFilePath');
      }

      _callStarted = false;

      if (_callConnectedTime != null) {
        final duration = DateTime.now().difference(_callConnectedTime!).inSeconds;
        debugPrint("Call duration: $duration seconds");
      }

      await _sendCallEndData();

      // Show the form dialog for reminder and remarks
      if (mounted) {
        _showReminderRemarksForm(context);
      }

      _callConnectedTime = null;
    }
  });
}
  //show reminder remarks form
Future<void> _showReminderRemarksForm(BuildContext context) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // makes background transparent
      barrierColor: Colors.transparent, // removes black overlay
pageBuilder: (_, __, ___) {
  return Scaffold(
    backgroundColor: Colors.black.withOpacity(0.5), // optional dim
    body: Center(
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: PostCallDetailsCard(),
      ),
    ),
  );
}

    ),
  );
}


  void _addDigit(String digit) {
    setState(() {
      phoneNumber += digit;
    });
  }

  void _deleteDigit() {
    if (phoneNumber.isNotEmpty) {
      setState(() {
        phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      });
    }
  }

Future<void> _sendCallData() async {
  if (_callDataSent) return; // ✅ Already sent

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    debugPrint("No token found!");
    return;
  }

  final now = DateTime.now();

  final url = Uri.parse("https://api.callman.in/api/user/call");

  final body = {
    "callerName": widget.userName ?? "Guest",
    "callerNumber": phoneNumber,
    "callType": 0,
    "callStartDate": now.toUtc().toIso8601String(),
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _callId = data['call']['_id'];
      await prefs.setString('callId', _callId!);
      _callDataSent = true; // ✅ Set flag
      debugPrint("Call started and logged with ID: $_callId");
    } else {
      debugPrint("Failed to send call data: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error sending call data: $e");
  }
}

  



Future<void> _sendCallEndData([int? duration]) async {
  if (_callId == null) {
    debugPrint("No callId to update.");
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    debugPrint("No token found!");
    return;
  }

  final now = DateTime.now();

  int? finalDuration = duration;
  
  if (finalDuration == null) {
    await Future.delayed(Duration(seconds: 2)); // 👈 delay before checking logs
    finalDuration = await getCallDuration(phoneNumber);
    debugPrint("Call duration from call log: $finalDuration");
  }

  final url = Uri.parse("https://api.callman.in/api/user/call/$_callId");

  final body = {
    "callEndDate": now.toUtc().toIso8601String(),
    if (finalDuration != null) "callDuration": finalDuration,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      debugPrint("Call ended and updated successfully.");
    } else {
      debugPrint("Failed to update call end: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error updating call end data: $e");
  } finally {
    _resetCallState(); // ✅ Reset flags
  }
}


void _resetCallState() {
  _callStarted = false;
  _callConnectedTime = null;
  _callId = null;
  _callDataSent = false;
  _recordCall = false;
}




Future<void> _makeCall() async {
  if (phoneNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a phone number")),
    );
    return;
  }

  bool? userWantsToRecord = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Record Call?"),
      content: const Text("Do you want to record this call?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Yes"),
        ),
      ],
    ),
  );

  _recordCall = userWantsToRecord ?? false;

  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
  }

  if (status.isGranted) {
    if (_recordCall) {
      await startRecording();
    }

    // ✅ REMOVE this line ↓↓↓
    // await FlutterCallkitIncoming.showCallkitIncoming(...);

    await Future.delayed(const Duration(seconds: 1));

    // 🔥 Make the actual call
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}




  // void _showCallingAlert() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.black,
  //       content: Text(
  //         'Calling as ${widget.userName ?? "Guest"}',
  //         style: const TextStyle(fontSize: 18, color: Colors.white),
  //       ),
  //     ),
  //   );

  //   Future.delayed(const Duration(seconds: 1), () {
  //     Navigator.of(context).pop();
  //   });
  // }

  Widget _buildDialButton(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        onTap: () {
          HapticFeedback.selectionClick();
          _addDigit(label);
        },
        child: Center(
          child: SizedBox(
            width: 70,
            height: 70,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              phoneNumber,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: buttons.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (_, index) {
                  return _buildDialButton(buttons[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: ()async{
                    await _showInteractionPopupAndCall();
                  },
                  child: const Icon(Icons.call, color: Colors.white),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: _deleteDigit,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.backspace_outlined, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}



