import 'package:callman/Custom%20Components/CustomerStageRow.dart';
import 'package:flutter/material.dart';

class CustomerStats extends StatelessWidget {
  const CustomerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "0 Total Customers",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const CustomerStageRow(stage: "Start", color: Colors.orange),
            const CustomerStageRow(stage: "In Progress", color: Colors.blue),
            const CustomerStageRow(stage: "Closed Won", color: Colors.green),
            const CustomerStageRow(stage: "Closed Lost", color: Colors.red),
          ],
        ),
      ),
    );
  }
}