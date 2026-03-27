import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/provider/map_provider.dart';
import 'package:last_hope_map/provider/tile_provider.dart';
import 'package:last_hope_map/screen/search_screen.dart';
import 'package:last_hope_map/service/tile_download_service.dart';
import 'package:latlong2/latlong.dart';

class DownloadManager extends ConsumerStatefulWidget {
  const DownloadManager({super.key});

  @override
  ConsumerState<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends ConsumerState<DownloadManager> {
  String? _selectedCountry;
  final List<String> _countries = [];
  List<Map> _downloadedRegions = [];
  bool _showDownloadedRegions = false;
  final TileDownloadService _downloadService = TileDownloadService();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadDownloadedRegions();
  }

  Future<void> _loadCountries() async {
    final service = ref.read(countryDataServiceProvider);
    await service.loadData();
    final countries = service.getAllCountries().map((c) => c.name).toList();
    setState(() {
      _countries.clear();
      _countries.addAll(countries);
    });
  }

  Future<void> _loadDownloadedRegions() async {
    final tileService = ref.read(tileDownloadServiceProvider);
    final regions = tileService.getDownloadedRegions();
    setState(() {
      _downloadedRegions = regions;
    });
  }

  Future<void> _download() async {
    if (_selectedCountry == null) return;
    
    final service = ref.read(countryDataServiceProvider);
    final bounds = service.getCountryBounds(_selectedCountry!);
    final tileService = ref.read(tileDownloadServiceProvider);
    
    // Enhanced zoom levels for better offline experience
    final zoomLevels = [6, 7, 8, 9, 10, 11, 12];
    
    // Estimate download size
    final tileCount = tileService.estimateTileCount(
      LatLngBounds(
        LatLng(bounds.$1, bounds.$3), // south-west (minLat, minLon)
        LatLng(bounds.$2, bounds.$4), // north-east (maxLat, maxLon)
      ),
      zoomLevels,
    );
    
    final estimatedSize = (tileCount * 20 / 1024).toStringAsFixed(1); // Rough estimate in MB
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download $_selectedCountry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated size: $estimatedSize MB'),
            Text('Tile count: $tileCount'),
            Text('Zoom levels: ${zoomLevels.join(', ')}'),
            const SizedBox(height: 8),
            const Text('Download will continue in background even if app is minimized.'),
            const SizedBox(height: 8),
            const Text('This may take several minutes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    // Start in-app download
    final boundsForDownload = LatLngBounds(
      LatLng(bounds.$1, bounds.$3), // south-west (minLat, minLon)
      LatLng(bounds.$2, bounds.$4), // north-east (maxLat, maxLon)
    );

    debugPrint('🔄 DownloadManager: Starting download...');
    setState(() {
      _isDownloading = true;
    });

    try {
      await _downloadService.downloadArea(
        boundsForDownload,
        zoomLevels,
        (int downloaded, int total) {
          ref.read(downloadProgressProvider.notifier).updateProgress(downloaded / total);
        },
        _selectedCountry!,
      );
      
      await _loadDownloadedRegions(); // Refresh downloaded regions
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedCountry downloaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ref.read(downloadProgressProvider.notifier).updateProgress(null);
      }
    }
  }

  Future<void> _deleteRegion(String regionName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $regionName'),
        content: Text('This will remove all offline map data for $regionName.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    final tileService = ref.read(tileDownloadServiceProvider);
    await tileService.deleteRegion(regionName);
    await _loadDownloadedRegions(); // Refresh list
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$regionName deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(downloadProgressProvider);
    final tileService = ref.read(tileDownloadServiceProvider);
    final storageInfo = tileService.getStorageInfo();

    return PopScope(
      canPop: !_isDownloading,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Offline Maps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showDownloadedRegions = !_showDownloadedRegions;
                      });
                    },
                    child: Text(_showDownloadedRegions ? 'Download' : 'Manage'),
                  ),
                  IconButton(
                    onPressed: _isDownloading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: _isDownloading ? 'Cannot close while downloading' : 'Close',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_showDownloadedRegions) ...[
            // Download section
            Text('Storage: ${storageInfo['totalTiles']} tiles (~${(storageInfo['estimatedSize'] / 1024).toStringAsFixed(1)} MB)'),
            const SizedBox(height: 16),
            
            if (_countries.isEmpty)
              const CircularProgressIndicator()
            else
              DropdownButton<String>(
                value: _selectedCountry,
                hint: const Text('Select a country'),
                isExpanded: true,
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),
            const SizedBox(height: 16),
            
            if (_isDownloading && progress != null) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text('${(progress * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
            ],
            
            ElevatedButton(
              onPressed: _isDownloading ? null : _download,
              child: Text(_isDownloading ? 'Downloading...' : 'Download Country'),
            ),

            if(_isDownloading) ...[
              Text('Download in progress:\n• Dialog cannot be closed during download\n• Download will continue even if app is minimized\n• Please wait for completion', style: TextStyle(fontSize: 8, color: Colors.redAccent),)
            ]
          ] else ...[
            // Management section
            SizedBox(
              height: 200,
              child: _downloadedRegions.isEmpty
                  ? const Center(child: Text('No downloaded regions'))
                  : ListView.builder(
                      itemCount: _downloadedRegions.length,
                      itemBuilder: (context, index) {
                        final region = _downloadedRegions[index];
                        final regionName = region['name'] as String;
                        return ListTile(
                          title: Text(regionName),
                          subtitle: Text(
                            '${region['tileCount']} tiles • ${DateTime.parse(region['downloadDate']).day}/${DateTime.parse(region['downloadDate']).month}/${DateTime.parse(region['downloadDate']).year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRegion(regionName),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}