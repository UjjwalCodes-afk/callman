// lib/reminder_channel.dart
import 'package:flutter/services.dart';

class NativeReminder {
  static const MethodChannel _channel = MethodChannel('com.example.reminder');

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int epochMillis,
  }) async {
    await _channel.invokeMethod('scheduleReminder', {
      'id': id,
      'title': title,
      'body': body,
      'epochMillis': epochMillis,
    });
  }

  static Future<void> setSystemAlarm({
    required int hour,
    required int minute,
    required String message,
    bool skipUi = false,
  }) async {
    await _channel.invokeMethod('setSystemAlarm', {
      'hour': hour,
      'minute': minute,
      'message': message,
      'skipUi': skipUi,
    });
  }
}