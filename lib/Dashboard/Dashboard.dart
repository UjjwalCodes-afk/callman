import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Color primaryColor = const Color(0xFFFA5560);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Pkjsnsn",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text("U", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: primaryColor.withOpacity(0.1),
              ),
              child: Text(
                "Default process",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
              ),
            ),

            // Filter Tabs
            const SizedBox(height: 24),
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: ["Today", "Y'Day", "Last 7 Days", "Last 30 Days"]
        .map((text) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterTab(text: text, isActive: text == "Today"),
            ))
        .toList(),
  ),
),


            const SizedBox(height: 24),
            // Call Stats
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    StatusCard(title: "Connected", count: 0),
                    StatusCard(title: "Not Connected", count: 0),
                    StatusCard(title: "Personal", count: 0),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Talk Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                TalkTimeWidget(title: "Average Talk Time", time: "0m 0s"),
                TalkTimeWidget(title: "Total Talk Time", time: "0m 0s"),
              ],
            ),

            const SizedBox(height: 24),
            // Let's Get Started
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.waving_hand_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Let's Get Started",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Text("0%", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Start"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("CUSTOMERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const CustomerStats(),

            const SizedBox(height: 24),
            const Text("OPEN ACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                ActionItem(icon: Icons.assignment, label: "Allocations"),
                ActionItem(icon: Icons.event_note, label: "Follow-ups"),
                ActionItem(icon: Icons.call_missed, label: "Missed Calls"),
              ],
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FilterTab extends StatelessWidget {
  final String text;
  final bool isActive;

  const FilterTab({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      backgroundColor: isActive ? Colors.black : Colors.grey[300],
      label: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final int count;

  const StatusCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class TalkTimeWidget extends StatelessWidget {
  final String title;
  final String time;

  const TalkTimeWidget({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class CustomerStats extends StatelessWidget {
  const CustomerStats();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.person_outline),
                SizedBox(width: 10),
                Text("0 Total Customers", style: TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            const CustomerStageRow(stage: "Start"),
            const CustomerStageRow(stage: "In Progress"),
            const CustomerStageRow(stage: "Closed Won"),
            const CustomerStageRow(stage: "Closed Lost"),
          ],
        ),
      ),
    );
  }
}

class CustomerStageRow extends StatelessWidget {
  final String stage;

  const CustomerStageRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(child: Text(stage)),
          const Text("0.00%"),
          const SizedBox(width: 8),
          const Text("0"),
        ],
      ),
    );
  }
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.black87),
        const SizedBox(height: 5),
        const Text("0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
