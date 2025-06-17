import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InteractionScreen extends StatelessWidget {
  final Map<String, dynamic>? data; // Passed data from the API response
  final VoidCallback onCall;        // <-- NEW callback to trigger call

  const InteractionScreen({Key? key, this.data, required this.onCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final callerName = data?['callerName'];
    String resolvedCallerName;

    if (callerName is String) {
      resolvedCallerName = callerName;
    } else if (callerName is Map<String, dynamic> && callerName['name'] is String) {
      resolvedCallerName = callerName['name'];
    } else {
      resolvedCallerName = 'Unknown';
    }

    final call = data?['call'];
    final callDuration = call?['callDuration'] is int ? call['callDuration'] : 0;
    final startDateRaw = call?['callStartDate'];
    final remarks = call?['remarks'] ?? 'No remarks';
    final callType = call?['callType'] == 0 ? 'Outgoing' : 'Incoming';

    // Format date
    String formattedStartDate = 'N/A';
    if (startDateRaw is String) {
      final date = DateTime.tryParse(startDateRaw);
      if (date != null) {
        formattedStartDate = DateFormat('hh:mm a, dd MMM').format(date);
      }
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 480),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  callType,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Caller Name
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  resolvedCallerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LAST INTERACTION',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Interaction Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration: ${callDuration} sec',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start: $formattedStartDate',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    remarks.isEmpty ? 'No remarks' : remarks,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close popup
                      onCall();                     // Trigger the call
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add Interaction button pressed logic
                      // You can open another screen or form
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
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
