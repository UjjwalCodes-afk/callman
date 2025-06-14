// lib/Provider/CallProvider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CallProvider with ChangeNotifier {
  Future<List<Map<String, dynamic>>> getCalls(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('https://api.callman.in/api/user/calls'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> calls = List<Map<String, dynamic>>.from(data['calls'] ?? []);
      return calls;
    } else {
      debugPrint("Failed to fetch calls: ${response.statusCode}");
      return [];
    }
  }
}
