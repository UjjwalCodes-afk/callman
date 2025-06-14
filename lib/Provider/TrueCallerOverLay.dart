import 'package:flutter/material.dart';

class OverlayScreen extends StatelessWidget {
  final String callerName;
  final String callerNumber;

  const OverlayScreen({super.key, required this.callerName, required this.callerNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Incoming Call", style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 10),
              Text(callerName, style: const TextStyle(color: Colors.greenAccent, fontSize: 20)),
              const SizedBox(height: 5),
              Text(callerNumber, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      // Accept call logic
                    },
                    child: const Text("Accept"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      // Decline call logic
                    },
                    child: const Text("Decline"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
