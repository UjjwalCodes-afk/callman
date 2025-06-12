// appointment_screen.dart
import 'dart:convert';
import 'package:callman/Pages/DialPad.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DoctorHome.dart';
import 'Wallet.dart';

class AppointmentScreen extends StatefulWidget {
  final String email, userName;
  const AppointmentScreen(
      {super.key, required this.email, required this.userName});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedIndex = 1;
  bool _isUpcoming = true;
  List<Map<String, dynamic>> _upcoming = [], _past = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllCalls();
  }

  Future<List<Map<String, dynamic>>> fetchTodaysUpcomingCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('https://api.callman.in/api/user/calls/upcoming'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> calls = jsonDecode(response.body)['calls'] ?? [];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final filteredCalls = calls.where((call) {
      final start = DateTime.tryParse(call['callStartDate'] ?? '');
      return start != null &&
          start.isAfter(todayStart) &&
          start.isBefore(todayEnd);
    }).toList();

    filteredCalls.sort((a, b) {
      return DateTime.parse(a['callStartDate'])
          .compareTo(DateTime.parse(b['callStartDate']));
    });

    // ✅ Ensure type casting to List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(filteredCalls);
  }

  List<Map<String, dynamic>> getUpcomingSortedCalls(
      List<Map<String, dynamic>> allCalls) {
    final now = DateTime.now().toUtc();
    return allCalls.where((call) {
      final start = DateTime.tryParse(call['callStartDate'] ?? '')?.toUtc();
      final end = DateTime.tryParse(call['callEndDate'] ?? '')?.toUtc();

      // Valid only if start exists
      if (start == null) return false;

      // Upcoming = start is after now, or it's ongoing (start before now and end after now)
      final isUpcoming = start.isAfter(now) ||
          (end != null && start.isBefore(now) && end.isAfter(now));

      return isUpcoming;
    }).toList()
      ..sort((a, b) {
        final aDate =
            DateTime.tryParse(a['callStartDate'] ?? '') ?? DateTime(2000);
        final bDate =
            DateTime.tryParse(b['callStartDate'] ?? '') ?? DateTime(2000);
        return aDate.compareTo(bDate);
      });
  }

  //update calls

  Future<void> _fetchAllCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    // Use new function to get only today's upcoming calls
    _upcoming = await fetchTodaysUpcomingCalls();

    final res = await http.get(
      Uri.parse('https://api.callman.in/api/user/calls'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final calls = List<Map<String, dynamic>>.from(body['calls'] ?? []);

      final now = DateTime.now().toUtc();

      _past = calls.where((call) {
        final end = DateTime.tryParse(call['callEndDate'] ?? '')?.toUtc();
        return end != null && !end.isAfter(now);
      }).toList()
        ..sort((a, b) {
          final aDate =
              DateTime.tryParse(a['callEndDate'] ?? '') ?? DateTime(2000);
          final bDate =
              DateTime.tryParse(b['callEndDate'] ?? '') ?? DateTime(2000);
          return bDate.compareTo(aDate); // descending
        });
    } else {
      debugPrint('❌ Error fetching calls: ${res.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  void _onNav(int idx) {
    if (idx == _selectedIndex) return;
    Widget? target;
    if (idx == 0)
      target = DoctorHomeScreen(email: widget.email, userName: widget.userName);
    if (idx == 2) target = const DialPadScreen();
    if (idx == 3)
      target = Wallet(email: widget.email, userName: widget.userName);
    if (target != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => target!));
    }
    setState(() => _selectedIndex = idx);
  }
  

  @override
  Widget build(BuildContext context) {
    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (_isUpcoming ? _upcoming : _past).isEmpty
            ? Center(
                child:
                    Text(_isUpcoming ? 'No upcoming calls' : 'No past calls'))
            : ListView(
                children: (_isUpcoming ? _upcoming : _past)
                    .map((c) => AppointmentCard(callData: c))
                    .toList(),
              );

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Call Screen',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  _TabButton(
                      text: 'Upcoming',
                      isSelected: _isUpcoming,
                      onTap: () => setState(() => _isUpcoming = true)),
                  const SizedBox(width: 8),
                  _TabButton(
                      text: 'Past',
                      isSelected: !_isUpcoming,
                      onTap: () => setState(() => _isUpcoming = false)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: content),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00FFCB),
        unselectedItemColor: Colors.grey,
        onTap: _onNav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.call_missed_outgoing), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2))
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> callData;
  const AppointmentCard({super.key, required this.callData});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  late final TextEditingController _remarksCtrl;
  Map<String, dynamic> _call;
  DateTime? _reminderUtc;
  bool _updating = false;
  late final String _callId;
  bool _hasFetchedDetails = false;

  _AppointmentCardState() : _call = const {};

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }

  @override
  void initState() {
    super.initState();
    _call = widget.callData;
    _callId = _call['_id'];
    _remarksCtrl = TextEditingController(text: _call['remarks'] ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedDetails) {
      _hasFetchedDetails = true;
      _refreshCard();
    }
  }

  //fetch today upcoming calls

  Future<void> _updateCall() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final uri = Uri.parse('https://api.callman.in/api/user/call/$_callId');

    final body = {
      'remarks': _remarksCtrl.text,
      'reminder': _reminderUtc?.toIso8601String()
    };

    setState(() => _updating = true);

    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    print(res.statusCode);
    print(res.body);

    setState(() => _updating = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call updated successfully')),
      );
      _refreshCard(); // Refresh with updated data
    } else {
      debugPrint('❌ update $_callId → ${res.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update call')),
      );
    }
  }

Future<void> _refreshCard() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return;

  if (!mounted) return; // 👈 Safe check before setState
  setState(() => _updating = true);

  final res = await http.get(
    Uri.parse('https://api.callman.in/api/user/call/$_callId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (!mounted) return;

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body)['call'];
    _remarksCtrl.text = data['remarks'] ?? '';
    _reminderUtc = data['reminder'] != null
        ? DateTime.parse(data['reminder']).toUtc()
        : null;

    if (!mounted) return; // 👈 check again before next setState
    setState(() {
      _call = data;
      _updating = false;
    });
  } else {
    debugPrint('❌ fetch $_callId → ${res.statusCode}');
    if (!mounted) return; // 👈 final safety check
    setState(() => _updating = false);
  }
}


  /// ✅ Helper to filter and sort today's calls

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (t == null) return;

    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute).toUtc();
    setState(() => _reminderUtc = dt);
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  String _fmtIso(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt == null ? '-' : DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  String _fmtUtc(DateTime? dt) =>
      dt == null ? 'Tap to set' : DateFormat('d MMM yyyy, h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final c = _call;
    // final durationMin = ((c['callDuration'] ?? 0) / 60).ceil();
    final callType = (c['callType'] ?? 0) == 0 ? 'Outgoing' : 'Incoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00FFDA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  _fmtIso(c['callStartDate'] ?? ''),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (_updating)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Name & Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                        text: '${c['callerName']}\n',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(text: '${c['callerNumber']}'),
                  ],
                ),
              ),
              const Icon(Icons.phone, color: Colors.black),
            ],
          ),
          const SizedBox(height: 8),

          // Duration & Type
          Row(
            children: [
              const Icon(Icons.timer, size: 16),
              const SizedBox(width: 4),
              Text(formatDuration(c['callDuration'] ?? 0)),
              const Spacer(),
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 4),
              Text(callType),
            ],
          ),
          const SizedBox(height: 16),

          // Remarks
          const Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter remarks…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),

          // Reminder Picker
          const Text('Reminder:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickReminder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    _fmtUtc(_reminderUtc),
                    style: const TextStyle(fontSize: 14),
                  )),
                  const Icon(Icons.edit, size: 16, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

// Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _updating ? null : _updateCall,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
