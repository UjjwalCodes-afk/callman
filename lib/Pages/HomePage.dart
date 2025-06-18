import 'dart:async';
import 'dart:convert';
import 'package:call_log/call_log.dart';
import 'package:callman/Pages/DialPad.dart';
import 'package:callman/Pages/DoctorHome.dart';
import 'package:callman/Pages/Settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentScreen extends StatefulWidget {
  final String email, userName;
  const AppointmentScreen(
      {super.key, required this.email, required this.userName});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedIndex = 1;
  String _currentTab = 'all'; // 'all', 'missed', 'outgoing', 'incoming'
  late final ScrollController _scrollController = ScrollController();
  List<CallLogEntry> _callLogs = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  Map<String, Map<String, dynamic>> _callReminders = {};

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
    _loadReminders(); // Add this
  }
Future<void> _loadReminders() async {
  final prefs = await SharedPreferences.getInstance();
  final reminders = prefs.getStringList('call_reminders') ?? [];
  
  final Map<String, Map<String, dynamic>> reminderMap = {};
  for (final reminderJson in reminders) {
    try {
      final reminder = jsonDecode(reminderJson) as Map<String, dynamic>;
      // Use the same callId format as when creating reminders
      reminderMap[reminder['callId']] = reminder;
    } catch (e) {
      debugPrint('Error parsing reminder: $e');
    }
  }
  
  if (mounted) {
    setState(() {
      _callReminders = reminderMap;
    });
  }
}

  Future<void> _fetchCallLogs() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries.toList()
          ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
        _isLoading = false;
      });
      _loadReminders();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching call logs: $e');
    }
  }

  List<CallLogEntry> get _filteredCallLogs {
    switch (_currentTab) {
      case 'missed':
        return _callLogs.where((log) => log.callType == CallType.missed).toList();
      case 'outgoing':
        return _callLogs.where((log) => log.callType == CallType.outgoing).toList();
      case 'incoming':
        return _callLogs.where((log) => log.callType == CallType.incoming).toList();
      default:
        return _callLogs;
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(date);
  }

  String _formatDuration(int? duration) {
    if (duration == null || duration <= 0) return '0 sec';
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    if (minutes > 0) {
      return '$minutes min ${seconds} sec';
    }
    return '$seconds sec';
  }

  String _getCallType(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      default:
        return 'Unknown';
    }
  }

  IconData _getCallTypeIcon(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }

  Color _getCallTypeColor(CallType? type) {
    switch (type) {
      case CallType.missed:
        return Colors.red;
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Call Logs',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterTab(
                      text: 'All',
                      isSelected: _currentTab == 'all',
                      onTap: () => setState(() => _currentTab = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      text: 'Missed',
                      isSelected: _currentTab == 'missed',
                      onTap: () => setState(() => _currentTab = 'missed'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      text: 'Outgoing',
                      isSelected: _currentTab == 'outgoing',
                      onTap: () => setState(() => _currentTab = 'outgoing'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      text: 'Incoming',
                      isSelected: _currentTab == 'incoming',
                      onTap: () => setState(() => _currentTab = 'incoming'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Call logs list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _permissionDenied
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Permission to access call logs was denied'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => openAppSettings(),
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ),
                          )
                        : _filteredCallLogs.isEmpty
                            ? Center(
                                child: Text(
                                  'No ${_currentTab == 'all' ? '' : _currentTab} calls found',
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchCallLogs,
                                child: ListView.builder(
  controller: _scrollController,
  itemCount: _filteredCallLogs.length,
  itemBuilder: (context, index) {
    final log = _filteredCallLogs[index];
    // Create a consistent call ID - this should match how you save reminders
    final callId = '${log.number}_${log.timestamp}'; 
    final reminderData = _callReminders[callId];
    
    return CallLogCard(
      name: log.name ?? 'Unknown',
      number: log.number ?? 'Unknown',
      date: _formatDate(log.timestamp),
      duration: _formatDuration(log.duration),
      callType: log.callType,
      callTypeIcon: _getCallTypeIcon(log.callType),
      callTypeColor: _getCallTypeColor(log.callType),
      reminderData: reminderData,
    );
  },
)
                              ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00BFA5),
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

class _FilterTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterTab({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BFA5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF00BFA5).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// In your CallLogCard widget (replace the existing one):
class CallLogCard extends StatefulWidget {
  final String name;
  final String number;
  final String date;
  final String duration;
  final CallType? callType;
  final IconData callTypeIcon;
  final Color callTypeColor;
  final Map<String, dynamic>? reminderData;

  const CallLogCard({
    super.key,
    required this.name,
    required this.number,
    required this.date,
    required this.duration,
    required this.callType,
    required this.callTypeIcon,
    required this.callTypeColor,
    this.reminderData,
  });

  @override
  State<CallLogCard> createState() => _CallLogCardState();
}

class _CallLogCardState extends State<CallLogCard> {
  Timer? _timer;
  Duration? _timeRemaining;
  bool _isPast = false;
  String _formattedReminderTime = '';

  @override
  void initState() {
    super.initState();
    _initializeReminderData();
  }

  void _initializeReminderData() {
    if (widget.reminderData != null && widget.reminderData!['reminderTime'] != null) {
      final reminderTime = DateTime.fromMillisecondsSinceEpoch(
        widget.reminderData!['reminderTime'] as int
      );
      _formattedReminderTime = DateFormat('EEE MMM d HH:mm:ss yyyy').format(reminderTime);
      debugPrint("⏰ Reminder found for: $_formattedReminderTime");
      
      _updateRemainingTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateRemainingTime();
      });
    }
  }

  void _updateRemainingTime() {
    if (widget.reminderData == null || widget.reminderData!['reminderTime'] == null) return;
    
    final reminderTime = DateTime.fromMillisecondsSinceEpoch(
      widget.reminderData!['reminderTime'] as int
    );
    final now = DateTime.now();
    final difference = reminderTime.difference(now);
    
    setState(() {
      _timeRemaining = difference;
      _isPast = difference.isNegative;
    });
  }

  String _formatRemainingTime() {
    if (_timeRemaining == null) return '';
    
    if (_isPast) {
      return 'Was due on ${DateFormat('MMM dd, hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(widget.reminderData!['reminderTime'] as int)
      )
      }';
    }
    
    final duration = _timeRemaining!;
    if (duration.inDays > 0) {
      return 'Due in ${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return 'Due in ${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return 'Due in ${duration.inMinutes}m';
    } else {
      return 'Due in ${duration.inSeconds}s';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    debugPrint("Disposing timer for reminder card");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = widget.reminderData != null;
    final isMIUI = Theme.of(context).platform == TargetPlatform.android;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: isMIUI ? 1 : 2, // Adjust for MIUI devices
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caller info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  widget.callTypeIcon,
                  color: widget.callTypeColor,
                  size: 20,
                ),
              ],
            ),
            
            // Phone number
            const SizedBox(height: 6),
            Text(
              widget.number,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            
            // Call date and duration
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Reminder section
            if (hasReminder) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isPast ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isPast ? Colors.red[100]! : Colors.blue[100]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 16,
                      color: _isPast ? Colors.red[600] : Colors.blue[600],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reminderData?['remarks'] ?? 'Call reminder',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isPast ? Colors.red[600] : Colors.blue[600],
                            ),
                          ),
                          Text(
                            _formatRemainingTime(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _isPast ? Colors.red[600] : Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isPast)
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.red[600],
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}