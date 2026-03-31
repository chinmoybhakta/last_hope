import 'package:flutter/material.dart';

class TranslationInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  
  const TranslationInputField({
    super.key,
    required this.controller,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlignVertical: TextAlignVertical.bottom,
      decoration: InputDecoration(
        labelText: "Enter text to translate",
        hintText: "Type something...",
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.text_fields),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 4,
      enabled: enabled,
    );
  }
}