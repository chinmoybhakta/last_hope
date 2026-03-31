import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageModel {
  final String name;
  final TranslateLanguage mlKitLanguage;
  
  const LanguageModel({
    required this.name,
    required this.mlKitLanguage,
  });
}

class SupportedLanguages {
  static const List<LanguageModel> languages = [
    LanguageModel(name: 'English', mlKitLanguage: TranslateLanguage.english),
    LanguageModel(name: 'Bengali', mlKitLanguage: TranslateLanguage.bengali),
    LanguageModel(name: 'Hindi', mlKitLanguage: TranslateLanguage.hindi),
    LanguageModel(name: 'French', mlKitLanguage: TranslateLanguage.french),
    LanguageModel(name: 'German', mlKitLanguage: TranslateLanguage.german),
  ];
  
  static LanguageModel? getLanguageByName(String name) {
    return languages.firstWhere(
      (lang) => lang.name == name,
      orElse: () => languages.first,
    );
  }
}