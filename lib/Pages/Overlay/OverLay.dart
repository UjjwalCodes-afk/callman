import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayPage extends StatelessWidget {
  static const platform = MethodChannel('overlay_channel');

  Future<void> showOverlay() async {
    try {
      await platform.invokeMethod('showOverlay');
    } on PlatformException catch (e) {
      print("Failed to start overlay: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Overlay Launcher")),
      body: Center(
        child: ElevatedButton(
          onPressed: showOverlay,
          child: Text("Show Truecaller Overlay"),
        ),
      ),
    );
  }
}
