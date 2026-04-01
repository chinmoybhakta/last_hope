import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final Future<List<String>> Function(String) suggestionsCallback;
  final void Function(String) onSelected;
  final Color primaryColor;
  
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.enabled,
    required this.suggestionsCallback,
    required this.onSelected,
    required this.primaryColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: controller,
      suggestionsCallback: suggestionsCallback,
      builder: (context, controller, focusNode) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: enabled ? 'Search articles...' : 'Loading...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => controller.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty && enabled) {
                onSelected(value);
              }
            },
          ),
        );
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.article, color: primaryColor),
          title: Text(suggestion, style: const TextStyle(fontSize: 14)),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: () {
            controller.text = suggestion;
            onSelected(suggestion);
          },
        );
      },
      onSelected: (suggestion) {
        controller.text = suggestion;
        onSelected(suggestion);
      },
    );
  }
}