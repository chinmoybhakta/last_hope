import 'package:flutter/material.dart';
import 'package:last_hope_map/screen/map_screen.dart';
import 'package:last_hope_map/screen/search_screen.dart';

class OfflineMapApp extends StatelessWidget {
  const OfflineMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 OfflineMapApp: Building app');
    return MaterialApp(
      title: 'Offline Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 MainScreen: initState called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 MainScreen: Building with index $_selectedIndex');
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          debugPrint('🏠 MainScreen: Page changed to index $index');
          setState(() => _selectedIndex = index);
        },
        children: const [
          MapScreen(),
          SearchScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          debugPrint('🏠 MainScreen: Bottom nav tapped index $index');
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}