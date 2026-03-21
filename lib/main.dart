import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature/screens/ai_screens/login_screen.dart';
import 'feature/screens/ai_screens/model_browser_screen.dart';
import 'feature/screens/ai_screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/browse': (context) => const ModelBrowserScreen(),
      },
    );
  }
}