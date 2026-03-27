import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/model/country.dart';
import 'package:last_hope_map/provider/map_provider.dart';
import 'package:last_hope_map/provider/tile_provider.dart';
import 'package:last_hope_map/service/location_service.dart';
import 'package:last_hope_map/service/network_service.dart';
import 'package:last_hope_map/widget/debug_error_widget.dart';
import 'package:last_hope_map/widget/download_manager.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _hasNetwork = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🗺️ MapScreen: initState called');
    _getCurrentLocation();
    _checkNetworkConnectivity();
  }

  @override
  void dispose() {
    debugPrint('🗺️ MapScreen: dispose called');
    super.dispose();
  }

  Future<void> _checkNetworkConnectivity() async {
    debugPrint('🌐 Checking network connectivity...');
    final hasConnection = await NetworkService.hasInternetConnection();
    if (mounted) {
      setState(() {
        _hasNetwork = hasConnection;
      });
    }
    debugPrint('🌐 Network status: $hasConnection');
  }

  Future<void> _getCurrentLocation() async {
    debugPrint('🗺️ MapScreen: Getting current location...');
    final loc = await LocationService.getCurrentLocation();
    debugPrint('🗺️ MapScreen: Location result: $loc');
    
    if (loc != null) {
      debugPrint('🗺️ MapScreen: Updating location providers');
      ref.read(currentLocationProvider.notifier).updateLocation(loc);
      ref.read(mapCenterProvider.notifier).updateLocation(loc);
      ref.read(mapZoomProvider.notifier).updateZoom(12.0);
      debugPrint('🗺️ MapScreen: Moving map to location');
      _mapController.move(loc, 12.0);
    } else {
      debugPrint('🗺️ MapScreen: Location is null, showing permission dialog');
      await _showLocationPermissionDialog();
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This app needs location permission to show your current position and provide navigation.'),
            SizedBox(height: 16),
            Text('Please enable location services in your device settings.'),
            SizedBox(height: 16),
            Text('Steps:'),
            Text('1. Open device Settings'),
            Text('2. Go to Apps or Application Manager'),
            Text('3. Find this app and enable location permission'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _navigateToDestination() {
    debugPrint('🗺️ MapScreen: Starting navigation to destination');
    final destination = ref.read(selectedDestinationProvider);
    final current = ref.read(currentLocationProvider);
    
    debugPrint('🗺️ MapScreen: Destination: $destination');
    debugPrint('🗺️ MapScreen: Current location: $current');
    
    if (destination == null || current == null) {
      debugPrint('🗺️ MapScreen: Cannot navigate - destination or current location is null');
      return;
    }

    debugPrint('🗺️ MapScreen: Calculating detailed route...');
    // Use enhanced route calculation
    final route = LocationService.detailedRoute(current, LatLng(destination.latitude, destination.longitude));
    debugPrint('🗺️ MapScreen: Route calculated with ${route.length} points');
    
    ref.read(routePointsProvider.notifier).updateRoute(route);
    debugPrint('🗺️ MapScreen: Route points updated in provider');
    
    _fitRouteToMap(route);
  }

  void _fitRouteToMap(List<LatLng> route) {
    debugPrint('🗺️ MapScreen: Fitting route to map...');
    if (route.isEmpty) {
      debugPrint('🗺️ MapScreen: Route is empty, cannot fit');
      return;
    }
    
    double minLat = route[0].latitude, maxLat = route[0].latitude;
    double minLng = route[0].longitude, maxLng = route[0].longitude;
    
    for (final point in route) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }
    
    // Add padding to ensure both points are clearly visible
    final latPadding = (maxLat - minLat) * 0.1; // 10% padding
    final lngPadding = (maxLng - minLng) * 0.1; // 10% padding
    
    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;
    
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final zoom = _calculateOptimalZoom(minLat, maxLat, minLng, maxLng);
    debugPrint('🗺️ MapScreen: Route center: $center, zoom: $zoom');
    
    _mapController.move(center, zoom);
    debugPrint('🗺️ MapScreen: Camera moved to fit route with padding');
  }

  double _calculateOptimalZoom(double minLat, double maxLat, double minLng, double maxLng) {
    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();
    
    // Calculate the maximum distance to ensure both points are visible
    final maxDiff = max(latDiff, lngDiff);
    
    // Adjust zoom based on the distance
    // For very close points, use a higher zoom to show detail
    // For far points, use a lower zoom to fit both
    double zoom;
    if (maxDiff < 0.001) {
      // Very close points (same building/street level)
      zoom = 17.0;
    } else if (maxDiff < 0.01) {
      // Close points (neighborhood level)
      zoom = 15.0;
    } else if (maxDiff < 0.1) {
      // Medium distance (city level)
      zoom = 13.0;
    } else if (maxDiff < 0.5) {
      // Far distance (region level)
      zoom = 10.0;
    } else {
      // Very far distance (country level)
      zoom = 8.0;
    }
    
    // Ensure the zoom is within reasonable bounds
    return zoom.clamp(8.0, 17.0);
  }

  void _handleMapLongPress(LatLng point) {
    debugPrint('🗺️ MapScreen: Long press detected at: $point');
    
    // Create a SearchResult object from the tapped point
    final destination = SearchResult(
      name: 'Custom Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})', 
      type: 'custom',
      parent: '',
      latitude: point.latitude,
      longitude: point.longitude,
    );
    
    debugPrint('🗺️ MapScreen: Setting destination to: ${destination.name} at ${destination.latitude}, ${destination.longitude}');
    
    // Update the selected destination
    ref.read(selectedDestinationProvider.notifier).updateDestination(destination);
    
    // Show confirmation to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destination set: ${destination.name}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Navigate',
          onPressed: () {
            // Start navigation immediately
            _navigateToDestination();
          },
        ),
      ),
    );
    
    debugPrint('🗺️ MapScreen: Long press handler completed');
  }

  @override
  Widget build(BuildContext context) {
    final center = ref.watch(mapCenterProvider);
    final zoom = ref.watch(mapZoomProvider);
    final destination = ref.watch(selectedDestinationProvider);
    final current = ref.watch(currentLocationProvider);
    final route = ref.watch(routePointsProvider);
    final tileService = ref.watch(tileDownloadServiceProvider);
    final tileProvider = OfflineFirstTileProvider(tileService);

    return DebugErrorWidget(
      name: 'MapScreen',
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onPositionChanged: (pos, _) {
                  ref.read(mapCenterProvider.notifier).updateLocation(pos.center);
                  ref.read(mapZoomProvider.notifier).updateZoom(pos.zoom);
                },
                onLongPress: (tapPosition, point) {
                  _handleMapLongPress(point);
                },
              ),
            children: [
              TileLayer(
                tileProvider: tileProvider,
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.offline_navigation',
              ),
              if (current != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: current,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
                    ),
                  ],
                ),
              if (destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(destination.latitude, destination.longitude),
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 24),
                    ),
                  ],
                ),
              if (route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route,
                      color: Colors.blue,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                      pattern: StrokePattern.dotted(spacingFactor: 2),
                    ),
                  ],
                ),
            ],
          ),
          // Network status indicator
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _hasNetwork ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasNetwork ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _hasNetwork ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'location',
                  mini: true,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                if (destination != null && current != null)
                  FloatingActionButton(
                    heroTag: 'navigate',
                    mini: true,
                    onPressed: _navigateToDestination,
                    child: const Icon(Icons.navigation),
                  ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'download',
                  mini: true,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const DownloadManager(),
                    );
                  },
                  child: const Icon(Icons.download),
                ),
              ],
            ),
          ),
          if (destination != null && current != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destination: ${destination.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Distance: ${(LocationService.calculateDistance(current, LatLng(destination.latitude, destination.longitude)) / 1000).toStringAsFixed(1)} km'),
                      
                      // Add navigation instructions
                      for (final instruction in LocationService.getNavigationInstructions(current, LatLng(destination.latitude, destination.longitude)))
                        Text(instruction, style: const TextStyle(fontSize: 12)),
                      
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _navigateToDestination,
                              child: const Text('Start Navigation'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref.read(selectedDestinationProvider.notifier).updateDestination(null);
                              ref.read(routePointsProvider.notifier).updateRoute([]); // Clear route
                            },
                          ),
                        ],
                      ),
                    ],
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