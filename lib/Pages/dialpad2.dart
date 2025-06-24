import 'package:callman/Dashboard/Dashboard.dart';
import 'package:callman/Pages/Interaction.dart';
import 'package:flutter/material.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added import
import 'dart:async';

class DialPadScreen1 extends StatefulWidget {
  const DialPadScreen1({super.key});

  @override
  State<DialPadScreen1> createState() => _DialPadScreen1State();
}

class _DialPadScreen1State extends State<DialPadScreen1> {
  String _phoneNumber = "";
  bool _hasCalled = false;
  PhoneStateStatus status = PhoneStateStatus.NOTHING;

  StreamSubscription<PhoneState>? _phoneStateSubscription;
  DateTime? _callConnectedTime;
  bool _callStarted = false;
  bool _callDataSent = false;

  String? _userName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToPhoneState();
  }

  @override
  void dispose() {
    _phoneStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  void _listenToPhoneState() async {
    try {
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
        if (!status.isGranted) return;
      }

      _phoneStateSubscription?.cancel(); // Cancel if already subscribed
      _phoneStateSubscription = PhoneState.stream.listen((PhoneState event) async {
        debugPrint("Phone state changed: ${event.status}");

        if (event.status == PhoneStateStatus.CALL_STARTED && !_callStarted) {
          _callStarted = true;
          _callConnectedTime = DateTime.now();

          if (!_callDataSent) {
            await _sendCallData();
            _callDataSent = true;
          }
        }

if (event.status == PhoneStateStatus.CALL_ENDED && _callStarted) {
  _callStarted = false;
  int? duration;

  if (_callConnectedTime != null) {
    duration = DateTime.now().difference(_callConnectedTime!).inSeconds;
    debugPrint("Call duration: $duration seconds");
  }

  await _sendCallEndData(duration);

  if (mounted) {
    // Delay navigation slightly to prevent fast redirection
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              userName: _userName ?? '',
              email: _email ?? '',
            ),
          ),
          (route) => false,
        );
      }
    });
  }

  _callConnectedTime = null;
  _callDataSent = false;
  _hasCalled = false; // ✅ Reset only after the navigation completes
}

      });
    } catch (e) {
      debugPrint('Phone state listener error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error monitoring call state: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendCallData() async {
    debugPrint("Call data sent (start). You can replace this with your API call.");
  }

  Future<void> _sendCallEndData(int? duration) async {
    debugPrint("Call ended. Duration: $duration seconds. You can replace this with your API call.");
  }

  void _addDigit(String digit) {
    setState(() => _phoneNumber += digit);
  }

  void _deleteDigit() {
    if (_phoneNumber.isNotEmpty) {
      setState(() => _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1));
    }
  }

  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place call')),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchLastInteraction(String number) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "callerName": "Contact for $number",
      "phoneNumber": number,
      "call": {
        "callStartDate": DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        "callDuration": 180,
        "callType": 0,
        "remarks": "Spoke about project deadlines."
      }
    };
  }

  Future<void> _showInteractionAndCall() async {
    if (_phoneNumber.isEmpty || !mounted || _hasCalled) return;

    try {
      final interactionData = await _fetchLastInteraction(_phoneNumber);
      if (!mounted) return;

      _hasCalled = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InteractionScreen(
            phoneNumber: _phoneNumber,
            callerName: interactionData["callerName"],
          ),
        ),
      );

      await _makeCall();

      setState(() {
        _phoneNumber = '';
      });
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildDialButton(String v) {
    return GestureDetector(
      onTap: () => _addDigit(v),
      child: Container(
        height: 80,
        width: 80,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(v, style: const TextStyle(fontSize: 26))),
      ),
    );
  }

  Widget _buildDialPad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];
    return Column(
      children: rows.map((r) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: r.map(_buildDialButton).toList(),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dial Pad'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(_phoneNumber, style: const TextStyle(fontSize: 36, letterSpacing: 2)),
            const SizedBox(height: 30),
            _buildDialPad(),
            IconButton(
              icon: const Icon(Icons.backspace_outlined),
              color: Colors.grey[700],
              iconSize: 30,
              onPressed: _deleteDigit,
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showInteractionAndCall,
              child: Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.call, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
