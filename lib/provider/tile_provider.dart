import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/service/tile_download_service.dart';
import 'package:http/http.dart' as http;

final tileDownloadServiceProvider = Provider((ref) => TileDownloadService());

class OfflineFirstTileProvider extends TileProvider {
  final TileDownloadService _downloadService;

  OfflineFirstTileProvider(this._downloadService);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _OfflineFirstImageProvider(
      _downloadService,
      coordinates.x,
      coordinates.y,
      zoom: coordinates.z
    );
  }
}

class _OfflineFirstImageProvider extends ImageProvider<_OfflineFirstImageProvider> {
  final TileDownloadService _downloadService;
  final int zoom;
  final int x;
  final int y;

  _OfflineFirstImageProvider(this._downloadService, this.x, this.y, {required this.zoom});

  @override
  Future<_OfflineFirstImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(_OfflineFirstImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(_OfflineFirstImageProvider key, ImageDecoderCallback decode) async {
    debugPrint('🗺️ TileProvider: Loading tile: ${key.zoom}/${key.x}/${key.y}');
    
    // Try offline
    final bytes = await _downloadService.getTile(key.zoom, key.x, key.y);
    if (bytes != null) {
      debugPrint('🗺️ TileProvider: Tile found offline');
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    }

    debugPrint('🗺️ TileProvider: Tile not found offline, trying network...');
    
    // Check if we're in an area with offline data but this specific tile is missing
    final hasNearbyOfflineData = await _checkNearbyOfflineTiles(key.zoom, key.x, key.y);
    
    if (hasNearbyOfflineData) {
      debugPrint('🗺️ TileProvider: Nearby offline data exists but tile is missing');
      // This would be a good place to suggest downloading the full country
      // For now, we'll continue to network
    }

    // Fallback to network
    final url = 'https://tile.openstreetmap.org/${key.zoom}/${key.x}/${key.y}.png';
    debugPrint('🗺️ TileProvider: Fetching from network: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint('🗺️ TileProvider: Network tile loaded successfully');
        final buffer = await ui.ImmutableBuffer.fromUint8List(response.bodyBytes);
        return await decode(buffer);
      } else {
        debugPrint('🗺️ TileProvider: Network tile failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🗺️ TileProvider: Network error: $e');
    }
    
    throw Exception('Failed to load tile: $url');
  }

  Future<bool> _checkNearbyOfflineTiles(int zoom, int x, int y) async {
    // Check if nearby tiles exist in offline storage
    final nearbyOffsets = [
      (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)
    ];
    
    int foundNearby = 0;
    for (final (dx, dy) in nearbyOffsets) {
      final nearbyX = x + dx;
      final nearbyY = y + dy;
      if (await _downloadService.hasTile(zoom, nearbyX, nearbyY)) {
        foundNearby++;
      }
    }
    
    debugPrint('🗺️ TileProvider: Found $foundNearby/8 nearby offline tiles');
    return foundNearby >= 4; // At least half of nearby tiles are offline
  }
}