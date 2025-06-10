import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final String email;
  final String userName;

  final List<Map<String, String>> notifications = List.generate(
    4,
    (index) => {
      "name": "Mr.Jack",
      "message": "want to fix appointment with you for medical checkup.",
      "time": "5 min ago",
      "image": "https://i.imgur.com/BoN9kdC.png",
    },
  );

  NotificationScreen({required this.email, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back),
                  ),
                  Spacer(),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return NotificationCard(
                    name: item['name']!,
                    message: item['message']!,
                    time: item['time']!,
                    imageUrl: item['image']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageUrl;

  const NotificationCard({
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.cyanAccent[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 4),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(imageUrl),
            ),
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              message,
              style: TextStyle(height: 1.3),
            ),
            trailing: Icon(Icons.close),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                time,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
    );
  }
}
