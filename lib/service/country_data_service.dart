import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:last_hope_map/model/country.dart';

class CountryDataService {
  List<Country> _countries = [];
  bool _loaded = false;

  Future<void> loadData() async {
    if (_loaded) {
      debugPrint('🌍 CountryDataService: Data already loaded, skipping');
      return;
    }
    
    try {
      debugPrint('🌍 CountryDataService: Loading data from assets...');
      final jsonString = await rootBundle.loadString('assets/global_full_dataset.json');
      debugPrint('🌍 CountryDataService: JSON loaded, parsing...');
      
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> countriesList = jsonMap['countries'];
      
      _countries = countriesList.map((e) => Country.fromJson(e)).toList();
      _loaded = true;
      
      debugPrint('🌍 CountryDataService: Loaded ${_countries.length} countries');
      for (int i = 0; i < min(5, _countries.length); i++) {
        debugPrint('🌍 CountryDataService: Sample ${i+1}: ${_countries[i].name} (${_countries[i].latitude}, ${_countries[i].longitude})');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CountryDataService: Error loading data: $e');
      debugPrint('📚 CountryDataService: Stack trace: $stackTrace');
    }
  }

  List<SearchResult> search(String query) {
    if (!_loaded) return [];
    final lowerQuery = query.toLowerCase();
    final results = <SearchResult>[];

    for (final country in _countries) {
      if (country.name.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          name: country.name,
          type: 'country',
          parent: '',
          latitude: country.latitude,
          longitude: country.longitude,
        ));
      }
      for (final state in country.states) {
        if (state.name.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(
            name: state.name,
            type: 'state',
            parent: country.name,
            latitude: state.latitude,
            longitude: state.longitude,
          ));
        }
      }
    }
    return results;
  }

  // Get bounding box for a country
  (double minLat, double maxLat, double minLon, double maxLon) getCountryBounds(String countryName) {
    final country = _countries.firstWhere((c) => c.name == countryName);
    // Use the country's approximate bounds: we can use its center +/- a reasonable offset
    // For better accuracy, we would need predefined bounds. Here we use a simple approximation.
    final offset = 5.0; // degrees
    return (
      country.latitude - offset,
      country.latitude + offset,
      country.longitude - offset,
      country.longitude + offset
    );
  }

  // Get all countries
  List<Country> getAllCountries() {
    return _countries;
  }
}