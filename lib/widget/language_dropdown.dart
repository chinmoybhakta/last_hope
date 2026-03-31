import 'package:flutter/material.dart';
import 'package:last_hope_translator/model/language_model.dart';

class LanguageDropdown extends StatelessWidget {
  final String? selectedLanguage;
  final String label;
  final Function(String) onChanged;
  final bool enabled;
  
  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.label,
    required this.onChanged,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedLanguage,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.translate),
      ),
      items: SupportedLanguages.languages
          .map((lang) => DropdownMenuItem(
                value: lang.name,
                child: Text(lang.name),
              ))
          .toList(),
      onChanged: enabled ? (value) => onChanged(value!) : null,
      isExpanded: true,
    );
  }
}