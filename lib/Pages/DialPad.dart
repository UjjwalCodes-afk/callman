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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';



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
  // int callDuration = DateTime.now().difference(_callConnectedTime!).inSeconds;
  


@override
void initState() {
  super.initState();
  _listenToPhoneState();
  _setupCallKitListeners();
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


  void _setupCallKitListeners() {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    debugPrint('CallKit Event: ${event?.event}');

    switch (event?.event) {
      case Event.actionCallAccept:
        _callConnectedTime = DateTime.now();
        _callStarted = true;
        await _sendCallData(); // Only when answered
        break;

      case Event.actionCallEnded:
      case Event.actionCallTimeout:
        if (_callStarted && _callConnectedTime != null) {
          final duration = DateTime.now().difference(_callConnectedTime!).inSeconds;
          debugPrint("Call duration via CallKit: $duration seconds");
          await _sendCallEndData(duration);
        } else {
          await _sendCallEndData(); // Missed/declined
        }
        _callStarted = false;
        _callConnectedTime = null;
        break;

      case Event.actionCallDecline:
        debugPrint("User declined the call.");
        await _sendCallEndData();
        _callStarted = false;
        _callConnectedTime = null;
        break;

      default:
        // Other events: ringing, etc.
        break;
    }
  });
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
  await Future.delayed(Duration(seconds: 2)); // Optional: allow for connection delay

  // Check again in case the call ended meanwhile
  if (!_callStarted) {
    _callStarted = true;
    _callConnectedTime = DateTime.now(); // More accurate after delay
    await _sendCallData();
  }
}




if (event.status == PhoneStateStatus.CALL_ENDED && _callStarted) {
  _callStarted = false;

  if (_callConnectedTime != null) {
    final duration = DateTime.now().difference(_callConnectedTime!).inSeconds;
    debugPrint("Call duration: $duration seconds");

    // Optional: send duration to server
    // Or modify _sendCallEndData to accept it
  }

  await _sendCallEndData();
  _callConnectedTime = null; // Reset for next call
}

    });
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
}



Future<void> _makeCall() async {
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
  }

  if (status.isGranted && phoneNumber.isNotEmpty) {
    _showCallingAlert();
    final callUUID = DateTime.now().millisecondsSinceEpoch.toString();

    // Step 1: Show CallKit screen
    await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      id: callUUID,
      nameCaller: widget.userName ?? 'Guest',
      handle: phoneNumber,
      type: 0, // Audio
      extra: {'userId': widget.email ?? ""},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'https://example.com/bg.png',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(),
    ));

    // Step 2: Delay a little and start call
    await Future.delayed(const Duration(seconds: 2));
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}


  void _showCallingAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        content: Text(
          'Calling as ${widget.userName ?? "Guest"}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

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
                  onPressed: _makeCall,
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



