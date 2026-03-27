import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static double calculateDistance(LatLng start, LatLng end) {
    const double R = 6371e3; // meters
    final phi1 = start.latitude * pi / 180;
    final phi2 = end.latitude * pi / 180;
    final deltaPhi = (end.latitude - start.latitude) * pi / 180;
    final deltaLambda = (end.longitude - start.longitude) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) *
        sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Enhanced route calculation with waypoints
  static List<LatLng> calculateRoute(LatLng start, LatLng end, {int waypoints = 50}) {
    final points = <LatLng>[];
    
    // Generate waypoints along the route
    for (int i = 0; i <= waypoints; i++) {
      final t = i / waypoints;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }

  // Simple straight line route (fallback)
  static List<LatLng> simpleRoute(LatLng start, LatLng end) {
    return calculateRoute(start, end, waypoints: 100);
  }

  // Calculate route with intermediate waypoints for better navigation
  static List<LatLng> detailedRoute(LatLng start, LatLng end) {
    final points = <LatLng>[];
    const steps = 200; // More points for smoother route
    
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }

  // Get navigation instructions for the route
  static List<String> getNavigationInstructions(LatLng start, LatLng end) {
    final distance = calculateDistance(start, end);
    final bearing = calculateBearing(start, end);
    final direction = getDirectionFromBearing(bearing);
    
    return [
      'Head $direction for ${(distance / 1000).toStringAsFixed(1)} km',
      'Destination will be on your ${direction.toLowerCase()}',
    ];
  }

  // Calculate bearing between two points
  static double calculateBearing(LatLng start, LatLng end) {
    final deltaLambda = (end.longitude - start.longitude) * pi / 180;
    final phi1 = start.latitude * pi / 180;
    final phi2 = end.latitude * pi / 180;
    
    final y = sin(deltaLambda) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    final bearing = atan2(y, x);
    
    return (bearing * 180 / pi + 360) % 360;
  }

  // Get direction from bearing
  static String getDirectionFromBearing(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    return 'Northwest';
  }

  // Check if point is within route bounds
  static bool isPointNearRoute(LatLng point, List<LatLng> route, {double threshold = 100}) {
    for (final routePoint in route) {
      if (calculateDistance(point, routePoint) <= threshold) {
        return true;
      }
    }
    return false;
  }

  static Future<LatLng?> getCurrentLocation() async {
    try {
      debugPrint('🔍 Starting location acquisition...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled.');
        // Try to open location settings
        await _openLocationSettings();
        return null;
      }
      debugPrint('✅ Location services are enabled');

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📋 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('📋 Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permissions are denied');
          await _showLocationPermissionDialog();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permissions are permanently denied');
        await _showLocationPermissionDialog();
        return null;
      }
      
      debugPrint('✅ Starting position acquisition...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      ).timeout(const Duration(seconds: 15));
      
      final location = LatLng(position.latitude, position.longitude);
      debugPrint('📍 Location acquired: ${location.latitude}, ${location.longitude}');
      return location;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting location: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> _openLocationSettings() async {
    debugPrint('🔧 Opening location settings...');
    // Note: This requires the android.permission.ACCESS_FINE_LOCATION permission
    // and may not work on all devices
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('❌ Could not open location settings: $e');
    }
  }

  static Future<void> _showLocationPermissionDialog() async {
    debugPrint('🔧 Showing location permission dialog...');
    // This would need to be implemented in the UI layer
    // For now, we'll just log it
  }

  static Future<void> openLocationSettings() async {
    debugPrint('🔧 Opening location settings...');
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('❌ Could not open location settings: $e');
    }
  }
}