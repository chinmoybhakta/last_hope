import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_ai/screen/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Last Hope',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.green[900]!,
          secondary: Colors.amber[700]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[900],
          elevation: 0,
        ),
      ),
      home: const SplashScreen()
    );
  }
}
