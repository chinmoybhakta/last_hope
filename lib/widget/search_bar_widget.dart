import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_map/provider/map_provider.dart';
import 'package:last_hope_map/screen/search_screen.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    debugPrint('🔍 SearchBarWidget: Text changed to: "${_controller.text}"');
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final text = _controller.text;
      debugPrint('🔍 SearchBarWidget: Debounced search for: "$text"');
      ref.read(searchQueryProvider.notifier).updateQuery(text);
      if (text.isNotEmpty) {
        final service = ref.read(countryDataServiceProvider);
        final results = service.search(text);
        debugPrint('🔍 SearchBarWidget: Found ${results.length} results');
        ref.read(searchResultsProvider.notifier).updateResults(results);
      } else {
        debugPrint('🔍 SearchBarWidget: Clearing results');
        ref.read(searchResultsProvider.notifier).updateResults([]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search country or state',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}