import 'package:flutter/material.dart';
import 'package:last_hope_translator/screen/translator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Language Offline Translator',
      debugShowCheckedModeBanner: false,
      home: TranslatorScreen(),
    );
  }
}