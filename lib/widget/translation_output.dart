import 'package:flutter/material.dart';

class TranslationOutput extends StatelessWidget {
  final String translatedText;
  final bool isTranslating;
  
  const TranslationOutput({
    super.key,
    required this.translatedText,
    this.isTranslating = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (translatedText.isEmpty && !isTranslating) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.translate_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Translation will appear here',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Translation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const Divider(),
          if (isTranslating)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            SelectableText(
              translatedText,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
        ],
      ),
    );
  }
}