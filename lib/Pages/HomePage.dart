/// appointment_screen.dart
import 'dart:convert';

import 'package:callman/Pages/DialPad.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DoctorHome.dart';
import 'Wallet.dart';

class AppointmentScreen extends StatefulWidget {
  final String email;
  final String userName;

  const AppointmentScreen({
    super.key,
    required this.email,
    required this.userName,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  /* ------------------------------------------------------------------ */
  /*  ────────────────────  high-level page state  ──────────────────── */
  /* ------------------------------------------------------------------ */
  int _selectedIndex = 1;
  bool _isUpcomingSelected = true;

  /// full call map for the single upcoming call (or `null`)
  Map<String, dynamic>? _upcomingCallDetails;

  /// list of full call maps for past calls
  List<Map<String, dynamic>> _pastCallDetails = [];

  @override
  void initState() {
    super.initState();
    _loadCallIdsAndFetch();
  }

  /* ------------------------------------------------------------------ */
  /*  ───────────────────────  persistence helpers  ─────────────────── */
  /* ------------------------------------------------------------------ */

  Future<void> _loadCallIdsAndFetch() async {
    final prefs = await SharedPreferences.getInstance();

    final upcomingId = prefs.getString('callId') ?? '';
    final pastIdsJson = prefs.getString('pastCallIds') ?? '[]';

    // decode the stored past-ids list (if any)
    List<String> pastIds = [];
    try {
      final decoded = jsonDecode(pastIdsJson);
      if (decoded is List) pastIds = List<String>.from(decoded);
    } catch (e) {
      debugPrint('Error decoding pastCallIds: $e');
    }

    /* ─────────── fetch upcoming & past details in sequence ────────── */
    Map<String, dynamic>? upcoming;
    if (upcomingId.isNotEmpty) {
      upcoming = await _fetchCall(upcomingId);
    }

    final List<Map<String, dynamic>> past = [];
    for (final id in pastIds) {
      final data = await _fetchCall(id);
      if (data != null) past.add(data);
    }

    /* ─────────────────────────── refresh UI ───────────────────────── */
    if (mounted) {
      setState(() {
        _upcomingCallDetails = upcoming;
        _pastCallDetails = past;
      });
    }
  }

  /// hits `GET /user/call/:callId` and returns the nested `"call"` map
  Future<Map<String, dynamic>?> _fetchCall(String callId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final url = Uri.parse('https://api.callman.in/api/user/call/$callId');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['call'];
    } else {
      debugPrint('Failed to fetch $callId  → ${res.statusCode}');
      return null;
    }
  }

  /* ------------------------------------------------------------------ */
  /*  ───────────────────────── bottom-nav tap ──────────────────────── */
  /* ------------------------------------------------------------------ */
  void _onItemTapped(int idx) {
    if (idx == _selectedIndex) return;

    switch (idx) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorHomeScreen(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DialPadScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Wallet(
              email: widget.email,
              userName: widget.userName,
            ),
          ),
        );
        break;
      default:
        break;
    }
    setState(() => _selectedIndex = idx);
  }

  /* ------------------------------------------------------------------ */
  /*  ─────────────────────────────  UI  ────────────────────────────── */
  /* ------------------------------------------------------------------ */
  @override
  Widget build(BuildContext context) {
    final List<Widget> listToRender = _isUpcomingSelected
        ? (_upcomingCallDetails != null
            ? [AppointmentCard(callData: _upcomingCallDetails!)]
            : [const Center(child: Text('No upcoming calls'))])
        : (_pastCallDetails.isNotEmpty
            ? _pastCallDetails.map((m) => AppointmentCard(callData: m)).toList()
            : [const Center(child: Text('No past calls'))]);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Call Screen',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _ToggleRow(
                isUpcoming: _isUpcomingSelected,
                onChanged: (b) => setState(() => _isUpcomingSelected = b),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: listToRender,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00FFCB),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  ────────────────────────  Toggle buttons  ──────────────────────── */
/* ------------------------------------------------------------------ */

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.isUpcoming, required this.onChanged});

  final bool isUpcoming;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          text: 'Upcoming',
          isSelected: isUpcoming,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _TabButton(
          text: 'Past',
          isSelected: !isUpcoming,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
}

/* ------------------------------------------------------------------ */
/*  ─────────────────────  Appointment card  ───────────────────────── */
/* ------------------------------------------------------------------ */

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({super.key, required this.callData});

  final Map<String, dynamic> callData;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(
      text: widget.callData['reminderRemarks'] ?? '', // Prefill if available
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt == null ? '-' : DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final callData = widget.callData;
    final callerName = callData['callerName'] ?? 'Unknown';
    final number = callData['callerNumber']?.toString() ?? '';
    final durationSec = callData['callDuration'] ?? 0;
    final durationMin = (durationSec / 60).ceil();
    final startIso = callData['callStartDate'] ?? '';
    final callType = callData['callType'] == 0 ? 'Outgoing' : 'Incoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00FFDA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_fmtDate(startIso), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(text: '$callerName\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(text: number),
                  ],
                ),
              ),
              const Icon(Icons.phone, color: Colors.black),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 16),
              const SizedBox(width: 4),
              Text('$durationMin min'),
              const Spacer(),
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 4),
              Text(callType),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Reminder Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            decoration: InputDecoration(
              hintText: 'Enter your remarks...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 2,
            onChanged: (value) {
              // Optionally update callData or call an API
              // For example:
              // _saveRemarksToBackend(value);
            },
          ),
        ],
      ),
    );
  }
}

