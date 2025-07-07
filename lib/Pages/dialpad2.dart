import 'package:callman/Dashboard/Dashboard.dart';
import 'package:callman/Pages/Interaction.dart';
import 'package:callman/Pages/PostCallsDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DialPadScreen1 extends StatefulWidget {
  const DialPadScreen1({super.key});

  @override
  State<DialPadScreen1> createState() => _DialPadScreen1State();
}

class _DialPadScreen1State extends State<DialPadScreen1> {
  bool _isRequestingPhonePermission = false;
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  List<CallLogEntry> _callLogs = [];
  int _currentIndex = 1; // Default tab: Dial Pad
  final Stream<CallEvent?> callEvent = FlutterCallkitIncoming.onEvent;
  String _phoneNumber = "";
  bool _hasCalled = false;
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final _uuid = const Uuid();
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  DateTime? _callConnectedTime;
  bool _callStarted = false;
  bool _callDataSent = false;
  bool _isLoadingCallLogs = false;

  String? _userName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _fetchCallLogs();
    Future.delayed(Duration(milliseconds: 100), _fetchCallLogs);
    _listenToPhoneState();
    
    _setupCallKitListeners();
    _requestContactsPermission();
    
    // Demo incoming call after delay
    Future.delayed(const Duration(seconds: 5), () {
      _showIncomingCall('Demo Caller', '+911234567890');
    });
  }

// / Update your permission request:
Future<void> _requestContactsPermission() async {
  final status = await FlutterContacts.requestPermission();
  if (!status) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission required')),
      );
    }
    return;
  }
  _fetchContacts();
}

// Update your _fetchContacts method:
Future<void> _fetchContacts() async {
  if (_contacts.isNotEmpty) return; // Skip if already loaded
  
  setState(() => _isLoadingContacts = true);
  try {
    if (await FlutterContacts.requestPermission()) {
      // Load contacts without photos first for faster display
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false, // Don't load photos initially
      );
      
      setState(() {
        _contacts = contacts
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
        _isLoadingContacts = false;
      });
      
      // Load photos in background after initial display
      _loadContactPhotos();
    }
  } catch (e) {
    debugPrint('Contacts error: $e');
    setState(() => _isLoadingContacts = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts: $e')),
      );
    }
  }
}

Future<void> _loadContactPhotos() async {
  try {
    final contactsWithPhotos = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );
    
    if (mounted) {
      setState(() {
        _contacts = contactsWithPhotos
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
      });
    }
  } catch (e) {
    debugPrint('Error loading contact photos: $e');
  }
}


Future<void> _fetchCallLogs() async {
  if (_isLoadingCallLogs || _isRequestingPhonePermission) return;

  setState(() {
    _isLoadingCallLogs = true;
    _isRequestingPhonePermission = true;
  });

  try {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone permission is required to load call logs.')),
        );
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
    );

    final sortedEntries = entries.toList()
      ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));

    if (mounted) {
      setState(() {
        _callLogs = sortedEntries.take(50).toList();
      });
    }

  } catch (e) {
    debugPrint('Error fetching call logs: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load call logs: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchCallLogs,
          ),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoadingCallLogs = false;
        _isRequestingPhonePermission = false;
      });
    }
  }
}



  Future<void> _showIncomingCall(String callerName, String phoneNumber) async {
    final callUUID = _uuid.v4();

    final params = CallKitParams.fromJson({
      'id': callUUID,
      'nameCaller': callerName,
      'appName': 'CallMan',
      'avatar': 'https://i.pravatar.cc/100',
      'handle': phoneNumber,
      'type': 0,
      'duration': 30000,
      'textAccept': 'Answer',
      'textDecline': 'Decline',
      'missedCallNotification': true,
      'android': {
        'isCustomNotification': true,
        'isShowLogo': true,
        'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        'actionColor': '#4CAF50'
      },
    });

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  void _setupCallKitListeners() {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      final String? eventType = event?.event as String?;

      switch (eventType) {
        case 'ACTION_CALL_ACCEPT':
          debugPrint("Call Accepted");
          break;
        case 'ACTION_CALL_DECLINE':
          debugPrint("Call Declined");
          break;
        case 'ACTION_CALL_ENDED':
          debugPrint("Call Ended");
          break;
        default:
          debugPrint("Unhandled event: $eventType");
          break;
      }
    });
  }

  Future<void> _showReminderRemarksForm(BuildContext context) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: Material(
                borderRadius: BorderRadius.circular(16),
                child: PostCallDetailsCard(
                  phoneNumber: _phoneNumber,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  // Add this method to show recent numbers dialog
Future<void> _showRecentNumbersDialog(BuildContext context) async {
  // Ensure call logs are loaded first
  if (_callLogs.isEmpty) {
    await _fetchCallLogs();
  }

  final recentNumbers = _callLogs
      .where((log) => log.number != null && log.number!.isNotEmpty)
      .map((log) => log.number!)
      .toSet() // Remove duplicates
      .take(5) // Limit to 5 most recent unique numbers
      .toList();

  if (recentNumbers.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recent calls found')),
      );
    }
    return;
  }

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Recent Numbers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: recentNumbers.length,
          itemBuilder: (context, index) {
            final number = recentNumbers[index];
            // Find the most recent call log entry for this number
            final callLog = _callLogs.firstWhere(
              (log) => log.number == number,
              orElse: () => _callLogs.first,
            );
            
            return ListTile(
              title: Text(number),
              subtitle: Text(
                _formatDate(callLog.timestamp),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Icon(
                _getCallTypeIcon(callLog.callType),
                color: _getCallTypeColor(callLog.callType),
              ),
              onTap: () {
                setState(() => _phoneNumber = number);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _listenToPhoneState() async {
  // Check if we're already requesting permissions
  if (_isRequestingPhonePermission) {
    return;
  }

  try {
    setState(() => _isRequestingPhonePermission = true);
    
    // Check current permission status
    var status = await Permission.phone.status;
    
    // Request if needed
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone permission is required for call monitoring')),
          );
        }
        return;
      }
    }

    // Cancel any existing subscription
    _phoneStateSubscription?.cancel();
    
    // Create new subscription
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
          await _showReminderRemarksForm(context);
          
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
        _hasCalled = false;
      }
    });
  } catch (e) {
    debugPrint('Phone state listener error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error monitoring call state: ${e.toString()}')),
      );
    }
  } finally {
    setState(() => _isRequestingPhonePermission = false);
  }
}

  Future<void> _sendCallData() async {
    debugPrint("Call data sent (start)");
  }

  Future<void> _sendCallEndData(int? duration) async {
    debugPrint("Call ended. Duration: $duration seconds");
  }

  void _addDigit(String digit) {
    setState(() => _phoneNumber += digit);
  }

  void _deleteDigit() {
    if (_phoneNumber.isNotEmpty) {
      setState(() =>
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1));
    }
  }

  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
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
        "callStartDate": DateTime.now()
            .subtract(const Duration(minutes: 45))
            .toIso8601String(),
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
      final callerName = interactionData["callerName"] ?? "Guest";

      _hasCalled = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InteractionScreen(
            phoneNumber: _phoneNumber,
            callerName: callerName,
          ),
        ),
      );

      _hasCalled = false;

      await _makeCall();

      setState(() {
        _phoneNumber = '';
      });
    } catch (e) {
      debugPrint('Error in _showInteractionAndCall: $e');
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
        child: Center(
          child: Text(
            v,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
          ),
        ),
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
      children: rows
          .map((r) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: r.map(_buildDialButton).toList(),
              ))
          .toList(),
    );
  }

  IconData _getCallTypeIcon(CallType? callType) {
    switch (callType) {
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

  Color _getCallTypeColor(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '0 sec';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return minutes > 0
        ? '$minutes min ${remainingSeconds} sec'
        : '$remainingSeconds sec';
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, y h:mm a').format(date);
    }
  }

  Widget _buildRecentsScreen() {
    if (_isLoadingCallLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_callLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No call history', style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: _fetchCallLogs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCallLogs,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _callLogs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final log = _callLogs[index];
          final phoneNumber = log.number ?? 'Unknown';
          final formattedNumber = phoneNumber.length > 15
              ? '${phoneNumber.substring(0, 12)}...'
              : phoneNumber;

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCallTypeColor(log.callType).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCallTypeIcon(log.callType),
                color: _getCallTypeColor(log.callType),
              ),
            ),
            title: Text(
              log.name ?? formattedNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(log.timestamp),
                  style: const TextStyle(fontSize: 12),
                ),
                if (log.duration != null && log.duration! > 0)
                  Text(
                    _formatDuration(log.duration),
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {
                if (phoneNumber != 'Unknown') {
                  setState(() {
                    _phoneNumber = phoneNumber;
                    _currentIndex = 1; // Switch to dial pad
                  });
                }
              },
            ),
            onTap: () {
              if (phoneNumber != 'Unknown') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InteractionScreen(
                      phoneNumber: phoneNumber,
                      callerName: log.name ?? 'Unknown',
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

Widget _buildContactsScreen() {
  if (_isLoadingContacts) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_contacts.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contacts, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No contacts found', style: TextStyle(fontSize: 18)),
          TextButton(
            onPressed: () {
              setState(() => _isLoadingContacts = true);
              _fetchContacts();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  final filteredContacts = _searchQuery.isEmpty
      ? _contacts
      : _contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phones = contact.phones.map((p) => p.number).toList();
          return name.contains(_searchQuery.toLowerCase()) ||
              phones.any((phone) => phone.contains(_searchQuery));
        }).toList();

  if (filteredContacts.isEmpty) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('No matching contacts found'),
          ),
        ),
      ],
    );
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            final phones = contact.phones;
            final primaryPhone = phones.isNotEmpty ? phones.first.number : 'No number';

            return ListTile(
              leading: (contact.photoOrThumbnail != null)
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(contact.photoOrThumbnail!),
                    )
                  : CircleAvatar(
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : '?',
                      ),
                    ),
              title: Text(
                contact.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(primaryPhone),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: phones.isNotEmpty
                    ? () {
                        setState(() {
                          _phoneNumber = primaryPhone;
                          _currentIndex = 1;
                        });
                      }
                    : null,
              ),
              onTap: phones.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InteractionScreen(
                            phoneNumber: primaryPhone,
                            callerName: contact.displayName,
                          ),
                        ),
                      );
                    }
                  : null,
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildDialPadScreen() {
  return Column(
    children: [
      const SizedBox(height: 30),
      Text(
        _phoneNumber,
        style: const TextStyle(fontSize: 36, letterSpacing: 2),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
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
        onLongPress: () => _showRecentNumbersDialog(context),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.call, color: Colors.white, size: 32),
              const SizedBox(height: 2),
              Text(
                'Hold for recent',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 30),
    ],
  );
}

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildRecentsScreen();
      case 1:
        return _buildDialPadScreen();
      case 2:
        return _buildContactsScreen();
      default:
        return _buildDialPadScreen();
    }
  }

  @override
  void dispose() {
    _phoneStateSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Recents'
              : _currentIndex == 1
                  ? 'Dial Pad'
                  : 'Contacts',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _CallLogSearchDelegate(_callLogs),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            _fetchCallLogs();
          } else if (index == 2) {
            _fetchContacts();
          }
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dialpad),
            label: 'Dial Pad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
      ),
    );
  }
}

class _CallLogSearchDelegate extends SearchDelegate {
  final List<CallLogEntry> callLogs;

  _CallLogSearchDelegate(this.callLogs);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? callLogs
        : callLogs.where((log) {
            final name = log.name?.toLowerCase() ?? '';
            final number = log.number?.toLowerCase() ?? '';
            return name.contains(query.toLowerCase()) ||
                number.contains(query.toLowerCase());
          }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No matching calls found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final log = results[index];
        final phoneNumber = log.number ?? 'Unknown';
        final formattedNumber = phoneNumber.length > 15
            ? '${phoneNumber.substring(0, 12)}...'
            : phoneNumber;

        return ListTile(
          leading: Icon(
            _getCallTypeIcon(log.callType),
            color: _getCallTypeColor(log.callType),
          ),
          title: Text(log.name ?? formattedNumber),
          subtitle: Text(_formatDate(log.timestamp)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InteractionScreen(
                  phoneNumber: phoneNumber,
                  callerName: log.name ?? 'Unknown',
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCallTypeIcon(CallType? callType) {
    switch (callType) {
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

  Color _getCallTypeColor(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, y h:mm a').format(date);
  }
}