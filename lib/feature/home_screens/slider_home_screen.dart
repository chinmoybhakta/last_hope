import 'package:flutter/material.dart';
import 'ai_screen.dart';
import 'map.dart';
import 'nasa_screen.dart';
import 'translator_screen.dart';
import 'wiki_screen.dart';

class HomeSliderScreen extends StatefulWidget {
  const HomeSliderScreen({super.key});

  @override
  State<HomeSliderScreen> createState() => _HomeSliderScreenState();
}

class _HomeSliderScreenState extends State<HomeSliderScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;
  final int totalPages = 5;

  Widget _buildTopSlider(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(totalPages, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 6,
            decoration: BoxDecoration(
              color: currentPage >= index ? Colors.blue.shade900 : Colors.grey[800],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: _buildTopSlider(screenWidth),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                children: const [
                  AiScreen(),
                  MapScreen(),
                  TranslatorScreen(),
                  WikiScreen(),
                  NasaScreen(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: currentPage == index ? 12 : 8,
                    height: currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color:
                      currentPage == index ? Colors.blueAccent.shade700 : Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}