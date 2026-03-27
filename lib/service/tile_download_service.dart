import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class TileDownloadService {
  late Box<Uint8List> _tileBox;
  late Box<Map> _metadataBox;

  TileDownloadService() {
    _tileBox = Hive.box<Uint8List>('offline_tiles');
    _metadataBox = Hive.box<Map>('tile_metadata');
  }

  // Convert lat/lon to tile coordinates
  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180.0;
    return ((1.0 - (log(tan(latRad) + 1.0 / cos(latRad)) / pi)) / 2.0 * (1 << zoom)).floor();
  }

  // Get tile size estimate for a region
  int estimateTileCount(LatLngBounds bounds, List<int> zoomLevels) {
    int total = 0;
    for (final zoom in zoomLevels) {
      final xMin = _lonToTileX(bounds.west, zoom);
      final xMax = _lonToTileX(bounds.east, zoom);
      final yMin = _latToTileY(bounds.north, zoom);
      final yMax = _latToTileY(bounds.south, zoom);
      total += (xMax - xMin + 1) * (yMax - yMin + 1);
    }
    return total;
  }

  // Check if tiles are available for a region
  bool hasOfflineTiles(LatLngBounds bounds, List<int> zoomLevels) {
    for (final zoom in zoomLevels) {
      final xMin = _lonToTileX(bounds.west, zoom);
      final xMax = _lonToTileX(bounds.east, zoom);
      final yMin = _latToTileY(bounds.north, zoom);
      final yMax = _latToTileY(bounds.south, zoom);
      
      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          final key = '$zoom/$x/$y';
          if (!_tileBox.containsKey(key)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Download tiles for a bounding box at given zoom levels
  Future<void> downloadArea(
    LatLngBounds bounds,
    List<int> zoomLevels,
    Function(int downloaded, int total) onProgress,
    String? regionName,
  ) async {
    final totalTiles = <(int, int, int)>[];
    for (final zoom in zoomLevels) {
      final xMin = _lonToTileX(bounds.west, zoom);
      final xMax = _lonToTileX(bounds.east, zoom);
      final yMin = _latToTileY(bounds.north, zoom);
      final yMax = _latToTileY(bounds.south, zoom);
      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          totalTiles.add((zoom, x, y));
        }
      }
    }

    // Save metadata for this region
    if (regionName != null) {
      await _metadataBox.put(regionName, {
        'bounds': {
          'north': bounds.north,
          'south': bounds.south,
          'east': bounds.east,
          'west': bounds.west,
        },
        'zoomLevels': zoomLevels,
        'downloadDate': DateTime.now().toIso8601String(),
        'tileCount': totalTiles.length,
      });
    }

    int downloaded = 0;
    for (final (zoom, x, y) in totalTiles) {
      final key = '$zoom/$x/$y';
      if (_tileBox.containsKey(key)) {
        downloaded++;
        onProgress(downloaded, totalTiles.length);
        continue;
      }

      final url = 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'OfflineMapApp/1.0'},
        );
        if (response.statusCode == 200) {
          final bytes = Uint8List.fromList(response.bodyBytes);
          await _tileBox.put(key, bytes);
        }
      } catch (e) {
        // Log error but continue
        debugPrint('Failed to download $url: $e');
      }
      downloaded++;
      onProgress(downloaded, totalTiles.length);
      // Be kind to the tile server
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Get downloaded regions with names
  List<Map<String, dynamic>> getDownloadedRegions() {
    final regions = <Map<String, dynamic>>[];
    for (final key in _metadataBox.keys) {
      final metadata = _metadataBox.get(key);
      if (metadata != null) {
        regions.add({
          'name': key,
          ...metadata,
        });
      }
    }
    return regions;
  }

  // Delete region data
  Future<void> deleteRegion(String regionName) async {
    final metadata = _metadataBox.get(regionName);
    if (metadata != null) {
      final bounds = metadata['bounds'] as Map;
      final zoomLevels = List<int>.from(metadata['zoomLevels']);
      
      // Delete tiles for this region
      for (final zoom in zoomLevels) {
        final xMin = _lonToTileX(bounds['west'], zoom);
        final xMax = _lonToTileX(bounds['east'], zoom);
        final yMin = _latToTileY(bounds['north'], zoom);
        final yMax = _latToTileY(bounds['south'], zoom);
        
        for (int x = xMin; x <= xMax; x++) {
          for (int y = yMin; y <= yMax; y++) {
            final key = '$zoom/$x/$y';
            await _tileBox.delete(key);
          }
        }
      }
      
      // Delete metadata
      await _metadataBox.delete(regionName);
    }
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    return {
      'totalTiles': _tileBox.length,
      'totalRegions': _metadataBox.length,
      'estimatedSize': _tileBox.length * 20, // Rough estimate in KB
    };
  }

  Future<bool> hasTile(int zoom, int x, int y) async {
    final key = '$zoom/$x/$y';
    return _tileBox.containsKey(key);
  }

  Future<Uint8List?> getTile(int zoom, int x, int y) async {
    final key = '$zoom/$x/$y';
    return _tileBox.get(key);
  }
}