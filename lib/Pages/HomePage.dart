import 'dart:async';
import 'dart:convert';
import 'package:call_log/call_log.dart';
import 'package:callman/Dashboard/Dashboard.dart';
import 'package:callman/Pages/DialPad.dart';
import 'package:callman/Pages/dialpad2.dart';

// import 'package:callman/Pages/Settings.dart';
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
  final status = await Permission.phone.status;

  if (!status.isGranted) {
    // Optionally skip requesting again if already handled globally
    setState(() {
      _permissionDenied = true;
      _isLoading = false;
    });
    return;
  }

  try {
    final Iterable<CallLogEntry> entries = await CallLog.get();
    setState(() {
      _callLogs = entries.toList()
        ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
      _isLoading = false;
    });
    _loadReminders(); // Load reminders after logs are fetched
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
      target = DashboardScreen(email: widget.email, userName: widget.userName);
    if (idx == 2) target =  DialPadScreen1();
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
    
    return AnimatedCallCard(
      name: log.name ?? 'Unknown',
      number: log.number ?? 'Unknown',
      date: _formatDate(log.timestamp),
      duration: _formatDuration(log.duration),
      // callType: log.callType,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF00BFA5),
          unselectedItemColor: Colors.grey,
          onTap: _onNav,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Appointments"),
            BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
                                    BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: "Reminders",
            ),
                        BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: "Menu",
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Wallet'),
          ],
        ),
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



class AnimatedCallCard extends StatefulWidget {
  final String name;
  final String number;
  final String date;
  final String duration;
  final IconData callTypeIcon;
  final Color callTypeColor;
  final Map<String, dynamic>? reminderData;

  const AnimatedCallCard({
    Key? key,
    required this.name,
    required this.number,
    required this.date,
    required this.duration,
    required this.callTypeIcon,
    required this.callTypeColor,
    this.reminderData,
  }) : super(key: key);

  @override
  _AnimatedCallCardState createState() => _AnimatedCallCardState();
}

class _AnimatedCallCardState extends State<AnimatedCallCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _reminderController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _reminderAnimation;
  
  bool _isPressed = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _reminderController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _reminderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _reminderController,
      curve: Curves.bounceOut,
    ));

    // Start entrance animations
    _slideController.forward();
    if (hasReminder) {
      Future.delayed(Duration(milliseconds: 300), () {
        _reminderController.forward();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  bool get hasReminder => widget.reminderData != null;
  
  bool get _isPast {
    if (!hasReminder) return false;
    try {
      DateTime reminderTime = DateTime.parse(widget.reminderData!['dateTime']);
      return DateTime.now().isAfter(reminderTime);
    } catch (e) {
      return false;
    }
  }

  String _formatRemainingTime() {
    if (!hasReminder) return '';
    try {
      DateTime reminderTime = DateTime.parse(widget.reminderData!['dateTime']);
      Duration diff = reminderTime.difference(DateTime.now());
      
      if (diff.isNegative) {
        return 'Overdue by ${diff.abs().inHours}h ${diff.abs().inMinutes % 60}m';
      } else {
        return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  Widget _buildCallTypeIcon() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: value * 0.1,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.callTypeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.callTypeIcon,
                color: widget.callTypeColor,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderSection() {
    if (!hasReminder) return SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _reminderAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _reminderAnimation.value,
          child: Opacity(
            opacity: _reminderAnimation.value,
            child: Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPast 
                    ? [Colors.red[50]!, Colors.red[100]!]
                    : [Colors.blue[50]!, Colors.blue[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPast ? Colors.red[200]! : Colors.blue[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isPast ? Colors.red : Colors.blue).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 0.5,
                        child: Icon(
                          Icons.alarm,
                          size: 20,
                          color: _isPast ? Colors.red[600] : Colors.blue[600],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reminderData?['remarks'] ?? 'Call reminder',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isPast ? Colors.red[700] : Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 4),
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
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.red[600],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: () {
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with name and call type
                          Row(
                            children: [
                              Expanded(
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 500),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(-20 * (1 - value), 0),
                                      child: Opacity(
                                        opacity: value,
                                        child: Text(
                                          widget.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildCallTypeIcon(),
                            ],
                          ),
                          
                          // Phone number
                          SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-15 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    widget.number,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Date and duration row
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 700),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(-10 * (1 - value), 0),
                                      child: Opacity(
                                        opacity: value,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              widget.date,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(10 * (1 - value), 0),
                                    child: Opacity(
                                      opacity: value,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 16,
                                            color: Colors.grey[500],
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            widget.duration,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          
                          // Reminder section
                          _buildReminderSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}