import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InteractionScreen extends StatelessWidget {
  final Map<String, dynamic>? data; // Passed data from the API response

  const InteractionScreen({Key? key, this.data}) : super(key: key);

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

    // Debug the data structure
    print("Caller Name: $callerName");
    print("Call Data: $call");

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
        constraints: const BoxConstraints(maxHeight: 400),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
      ),
    );
  }
}
