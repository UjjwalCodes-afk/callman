import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InteractionScreen extends StatelessWidget {
  final Map<String, dynamic>? data; // Step 1

  const InteractionScreen({Key? key, this.data}) : super(key: key); // Step 2

  @override
  Widget build(BuildContext context) {
    // Safe extraction
    final callerName = data?['callerName']?['name'] ?? 'Unknown';
    print("Caller Name: $callerName");
    final call = data?['call'];
    final startDateRaw = call?['callStartDate'];
    final remarks = call?['remarks'] ?? 'No remarks';
    final callType = call?['callType'] == 0 ? 'Outgoing' : 'Incoming';

    // Format date
    String formattedStartDate = 'N/A';
    if (startDateRaw != null) {
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
            // Header Row with Close Button
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

            // Name
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  callerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Last Interaction Title
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

            // Last Interaction Box
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
                    formattedStartDate,
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

            // Add Interaction Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add action here
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
      ),
    );
  }
}
