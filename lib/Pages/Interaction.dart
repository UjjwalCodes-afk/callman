import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


class InteractionScreen extends StatefulWidget {
  final String phoneNumber;
  final String callerName;

  const InteractionScreen({
    Key? key,
    required this.phoneNumber,
    required this.callerName,
  }) : super(key: key);

  @override
  State<InteractionScreen> createState() => _InteractionScreenState();
}

class _InteractionScreenState extends State<InteractionScreen> {
  CallLogEntry? lastCall;

  @override
  void initState() {
    super.initState();
    fetchLastInteraction();
  }

  Future<void> fetchLastInteraction() async {
    final status = await Permission.phone.request();
    final callLogStatus = await Permission.phone.status;

    if (status.isGranted && callLogStatus.isGranted) {
      final Iterable<CallLogEntry> entries = await CallLog.query(
        number: widget.phoneNumber,
      );

      if (entries.isNotEmpty) {
        setState(() {
          lastCall = entries.first;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone permission denied')),
      );
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('hh:mm a, dd MMM').format(date);
  }

String getCallType(int? callTypeValue) {
  if (callTypeValue == null) return 'Unknown';

  // Try to safely convert int to CallType enum
  final callType = CallType.values.asMap().containsKey(callTypeValue)
      ? CallType.values[callTypeValue]
      : null;

  switch (callType) {
    case CallType.incoming:
      return 'Incoming';
    case CallType.outgoing:
      return 'Outgoing';
    case CallType.missed:
      return 'Missed';
    case CallType.rejected:
      return 'Rejected';
    case CallType.blocked:
      return 'Blocked';
    case CallType.voiceMail:
      return 'Voicemail';
    default:
      return 'Unknown';
  }
}

  @override
  Widget build(BuildContext context) {
    final call = lastCall;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaction Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Info
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.callerName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                getCallType(call?.callType?.index),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LAST INTERACTION',
                style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 8),

            // Call Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: call == null
                  ? const Text('No interaction found.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration: ${call.duration} sec',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start: ${formatDate(DateTime.fromMillisecondsSinceEpoch(call.timestamp ?? 0))}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'No remarks',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
            ),

            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final telUrl = Uri.parse('tel:${widget.phoneNumber}');
                      if (await canLaunchUrl(telUrl)) {
                        await launchUrl(telUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot launch dialer')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '📞 Call Now',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Add Interaction
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B2C49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'ADD INTERACTION',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
