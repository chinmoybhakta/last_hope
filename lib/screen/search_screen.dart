import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/provider/map_provider.dart';
import 'package:last_hope_map/service/country_data_service.dart';
import 'package:last_hope_map/widget/search_bar_widget.dart';
import 'package:last_hope_map/widget/search_results_list.dart';

final countryDataServiceProvider = Provider((ref) => CountryDataService());

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔍 SearchScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🔍 SearchScreen: Loading country data...');
      await ref.read(countryDataServiceProvider).loadData();
      debugPrint('🔍 SearchScreen: Country data loaded');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 SearchScreen: Building widget...');
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    
    debugPrint('🔍 SearchScreen: Query: "$query"');
    debugPrint('🔍 SearchScreen: Results count: ${results.length}');

    return Scaffold(
      appBar: AppBar(title: const Text('Search Location')),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: query.isEmpty
                ? const Center(child: Text('Type to search countries or states'))
                : results.isEmpty
                    ? const Center(child: Text('No results'))
                    : const SearchResultsList(),
          ),
        ],
      ),
    );
  }
}