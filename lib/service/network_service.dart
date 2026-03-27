import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Network check failed: $e');
      return false;
    }
  }

  static Future<bool> canReachOpenStreetMap() async {
    try {
      final response = await http.get(
        Uri.parse('https://tile.openstreetmap.org/0/0/0.png'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('OpenStreetMap connectivity check failed: $e');
      return false;
    }
  }
}
