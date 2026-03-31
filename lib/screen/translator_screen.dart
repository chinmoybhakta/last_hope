import 'package:flutter/material.dart';
import 'package:last_hope_translator/model/language_model.dart';
import 'package:last_hope_translator/service/translation_service.dart';
import 'package:last_hope_translator/widget/language_dropdown.dart';
import 'package:last_hope_translator/widget/status_indicator.dart';
import 'package:last_hope_translator/widget/translation_input_field.dart';
import 'package:last_hope_translator/widget/translation_output.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  
  LanguageModel? _sourceLanguage;
  LanguageModel? _targetLanguage;
  
  bool _isTranslating = false;
  bool _isTranslatorReady = false;
  String _statusMessage = "Select languages to begin";
  String _translatedText = "";
  
  @override
  void initState() {
    super.initState();
    // Set default languages
    _sourceLanguage = SupportedLanguages.languages.first;
    _targetLanguage = SupportedLanguages.languages[1]; // Bengali as target
  }
  
  Future<void> _setupTranslator() async {
    if (_sourceLanguage == null || _targetLanguage == null) return;
    
    final bool success = await _translationService.prepareTranslator(
      _sourceLanguage!,
      _targetLanguage!,
      (message) {
        setState(() {
          _statusMessage = message;
          _isTranslatorReady = message.contains('✅');
        });
      },
    );
    
    setState(() {
      _isTranslatorReady = success;
    });
  }
  
  Future<void> _translate() async {
    if (!_isTranslatorReady || _inputController.text.isEmpty) return;
    
    setState(() {
      _isTranslating = true;
      _statusMessage = "Translating...";
    });
    
    try {
      final result = await _translationService.translate(_inputController.text);
      setState(() {
        _translatedText = result;
        _statusMessage = "Translation complete ✅";
      });
    } catch (e) {
      setState(() {
        _translatedText = "";
        _statusMessage = "Error: $e";
      });
    } finally {
      setState(() => _isTranslating = false);
    }
  }
  
  @override
  void dispose() {
    _inputController.dispose();
    _translationService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline Translator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              
              // Source language dropdown
              LanguageDropdown(
                selectedLanguage: _sourceLanguage?.name,
                label: 'Source Language',
                onChanged: (lang) {
                  setState(() {
                    _sourceLanguage = SupportedLanguages.getLanguageByName(lang);
                    _translatedText = "";
                  });
                  _setupTranslator();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Target language dropdown
              LanguageDropdown(
                selectedLanguage: _targetLanguage?.name,
                label: 'Target Language',
                onChanged: (lang) {
                  setState(() {
                    _targetLanguage = SupportedLanguages.getLanguageByName(lang);
                    _translatedText = "";
                  });
                  _setupTranslator();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Status indicator
              StatusIndicator(
                message: _statusMessage,
                isReady: _isTranslatorReady,
                isLoading: !_isTranslatorReady && _statusMessage.contains('Downloading'),
              ),
              
              const SizedBox(height: 20),
              
              // Input field
              TranslationInputField(
                controller: _inputController,
                enabled: _isTranslatorReady,
              ),
              
              const SizedBox(height: 16),
              
              // Translate button
              ElevatedButton.icon(
                onPressed: _isTranslatorReady && !_isTranslating && _inputController.text.isNotEmpty
                    ? _translate
                    : null,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Output
              TranslationOutput(
                translatedText: _translatedText,
                isTranslating: _isTranslating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}