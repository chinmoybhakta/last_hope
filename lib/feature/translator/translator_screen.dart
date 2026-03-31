import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MultiLangTranslatorPage extends StatefulWidget {
  @override
  _MultiLangTranslatorPageState createState() =>
      _MultiLangTranslatorPageState();
}

class _MultiLangTranslatorPageState extends State<MultiLangTranslatorPage> {
  final TextEditingController _controller = TextEditingController();
  OnDeviceTranslator? _translator;
  bool _isTranslating = false;
  bool _isDownloading = false;
  bool _modelReady = false;
  String _translatedText = "";
  String _statusMessage = "Select languages to start";

  // Supported languages
  final Map<String, TranslateLanguage> _languages = {
    'English': TranslateLanguage.english,
    'Bengali': TranslateLanguage.bengali,
    'Hindi': TranslateLanguage.hindi,
    'French': TranslateLanguage.french,
    'German': TranslateLanguage.german,
  };

  String? _sourceLanguageName;
  String? _targetLanguageName;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setupTranslator(
      TranslateLanguage source, TranslateLanguage target) async {
    setState(() {
      _isDownloading = true;
      _modelReady = false;
      _statusMessage =
      "Checking if models are downloaded for ${_sourceLanguageName} → ${_targetLanguageName}…";
    });

    final modelManager = OnDeviceTranslatorModelManager();
    try {
      bool isSourceDownloaded =
      await modelManager.isModelDownloaded(source.bcpCode);
      bool isTargetDownloaded =
      await modelManager.isModelDownloaded(target.bcpCode);

      if (!isSourceDownloaded) {
        setState(() {
          _statusMessage = "Downloading model for ${_sourceLanguageName}…";
        });
        await modelManager.downloadModel(source.bcpCode);
      }

      if (!isTargetDownloaded) {
        setState(() {
          _statusMessage = "Downloading model for ${_targetLanguageName}…";
        });
        await modelManager.downloadModel(target.bcpCode);
      }

      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      setState(() {
        _modelReady = true;
        _isDownloading = false;
        _statusMessage =
        "Models ready for ${_sourceLanguageName} → ${_targetLanguageName} ✅";
      });
    } catch (e) {
      setState(() {
        _modelReady = false;
        _isDownloading = false;
        _statusMessage = "Error downloading models: $e";
      });
    }
  }

  Future<void> _translateText() async {
    if (!_modelReady || _controller.text.isEmpty || _translator == null) return;

    setState(() {
      _isTranslating = true;
      _translatedText = "";
      _statusMessage = "Translating…";
    });

    try {
      final result = await _translator!.translateText(_controller.text.trim());
      setState(() {
        _translatedText = result;
        _statusMessage = "Translation complete ✅";
      });
    } catch (e) {
      setState(() {
        _translatedText = "";
        _statusMessage = "Translation error: $e";
      });
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _translator?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi-Language Offline Translator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Source Language
            DropdownButtonFormField<String>(
              value: _sourceLanguageName,
              decoration: InputDecoration(
                labelText: "Select source language",
                border: OutlineInputBorder(),
              ),
              items: _languages.keys
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (lang) {
                setState(() {
                  _sourceLanguageName = lang;
                  _translatedText = "";
                });
                if (_sourceLanguageName != null && _targetLanguageName != null) {
                  _setupTranslator(_languages[_sourceLanguageName!]!,
                      _languages[_targetLanguageName!]!);
                }
              },
            ),
            SizedBox(height: 10),

            // Target Language
            DropdownButtonFormField<String>(
              value: _targetLanguageName,
              decoration: InputDecoration(
                labelText: "Select target language",
                border: OutlineInputBorder(),
              ),
              items: _languages.keys
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (lang) {
                setState(() {
                  _targetLanguageName = lang;
                  _translatedText = "";
                });
                if (_sourceLanguageName != null && _targetLanguageName != null) {
                  _setupTranslator(_languages[_sourceLanguageName!]!,
                      _languages[_targetLanguageName!]!);
                }
              },
            ),
            SizedBox(height: 10),

            Text(
              _statusMessage,
              style: TextStyle(
                color: _modelReady ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter text",
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),

            // Translate button
            ElevatedButton(
              onPressed: _modelReady && !_isTranslating ? _translateText : null,
              child: _isTranslating
                  ? SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text("Translate"),
            ),
            SizedBox(height: 20),

            // Translated text
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _translatedText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}