import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/provider/map_provider.dart';
import 'package:last_hope_map/screen/map_screen.dart';
import 'package:latlong2/latlong.dart';

class SearchResultsList extends ConsumerWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔍 SearchResultsList: Building widget...');
    final results = ref.watch(searchResultsProvider);
    
    debugPrint('🔍 SearchResultsList: Results count: ${results.length}');
    for (int i = 0; i < results.length; i++) {
      debugPrint('🔍 SearchResultsList: Result $i: ${results[i].name} (${results[i].latitude}, ${results[i].longitude})');
    }
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        debugPrint('🔍 SearchResultsList: Building item $index');
        final result = results[index];
        return ListTile(
          leading: Icon(result.type == 'country' ? Icons.public : Icons.location_city),
          title: Text(result.name),
          subtitle: result.type == 'state' ? Text('State in ${result.parent}') : null,
          onTap: () {
            debugPrint('🔍 SearchResultsList: Tapped on ${result.name}');
            ref.read(selectedDestinationProvider.notifier).updateDestination(result);
            ref.read(mapCenterProvider.notifier).updateLocation(LatLng(result.latitude, result.longitude));
            ref.read(mapZoomProvider.notifier).updateZoom(10.0);
            Navigator.push(context, MaterialPageRoute(builder: (_)=>MapScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: ${result.name}')),
            );
            debugPrint('🔍 SearchResultsList: Navigation triggered for ${result.name}');
          },
        );
      },
    );
  }
}