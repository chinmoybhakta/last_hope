import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/model/country.dart';
import 'package:latlong2/latlong.dart';

final mapCenterProvider = NotifierProvider<MapCenterNotifier, LatLng>(MapCenterNotifier.new);
final mapZoomProvider = NotifierProvider<MapZoomNotifier, double>(MapZoomNotifier.new);

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final searchResultsProvider = NotifierProvider<SearchResultsNotifier, List<SearchResult>>(SearchResultsNotifier.new);

final selectedDestinationProvider = NotifierProvider<SelectedDestinationNotifier, SearchResult?>(SelectedDestinationNotifier.new);
final currentLocationProvider = NotifierProvider<CurrentLocationNotifier, LatLng?>(CurrentLocationNotifier.new);
final routePointsProvider = NotifierProvider<RoutePointsNotifier, List<LatLng>>(RoutePointsNotifier.new);

final downloadProgressProvider = NotifierProvider<DownloadProgressNotifier, double?>(DownloadProgressNotifier.new);
final isDownloadingProvider = NotifierProvider<IsDownloadingNotifier, bool>(IsDownloadingNotifier.new);

class MapCenterNotifier extends Notifier<LatLng> {
  @override
  LatLng build() => const LatLng(20.0, 0.0);
  
  void updateLocation(LatLng location) {
    state = location;
  }
}

class MapZoomNotifier extends Notifier<double> {
  @override
  double build() => 3.0;
  
  void updateZoom(double zoom) {
    state = zoom;
  }
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void updateQuery(String query) {
    state = query;
  }
}

class SearchResultsNotifier extends Notifier<List<SearchResult>> {
  @override
  List<SearchResult> build() => [];
  
  void updateResults(List<SearchResult> results) {
    state = results;
  }
}

class SelectedDestinationNotifier extends Notifier<SearchResult?> {
  @override
  SearchResult? build() => null;
  
  void updateDestination(SearchResult? destination) {
    state = destination;
  }
}

class CurrentLocationNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;
  
  void updateLocation(LatLng? location) {
    state = location;
  }
}

class RoutePointsNotifier extends Notifier<List<LatLng>> {
  @override
  List<LatLng> build() => [];
  
  void updateRoute(List<LatLng> route) {
    state = route;
  }
}

class DownloadProgressNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  
  void updateProgress(double? progress) {
    state = progress;
  }
}

class IsDownloadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void updateDownloading(bool downloading) {
    state = downloading;
  }
}