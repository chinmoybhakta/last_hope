import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:last_hope/feature/home_screens/slider_home_screen.dart';

void main() => runApp(const MaterialApp(home: LastHopeScreen()));

class LastHopeScreen extends StatefulWidget {
  const LastHopeScreen({super.key});

  @override
  State<LastHopeScreen> createState() => _LastHopeScreenState();
}

class _LastHopeScreenState extends State<LastHopeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _colorAnimation =
        Tween<double>(begin: 0.65, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Drawer _buildDrawer(double screenWidth) {
    return Drawer(
      backgroundColor: Colors.black45,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              "Last Hope",
              style: TextStyle(
                fontSize: screenWidth * 0.12,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: 'Cursive',
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),

            const Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.white),
              title: const Text(
                "Privacy Policy",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text(
                "About",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: _buildDrawer(screenWidth),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,

      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dark_sky_03.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    'assets/images/earth_gif_2.webp',
                    width: screenWidth,
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              const Color(0xFFA6A6FF)
                                  .withOpacity(_colorAnimation.value),
                              Colors.white
                                  .withOpacity(_colorAnimation.value),
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Last Hope!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.12,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Cursive',
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Text(
                          "Last Hope is your ultimate survival companion.\n\n"
                              "• 🧠 Offline AI Survivor\n"
                              "• 🗺️ Offline Map\n"
                              "• 🌐 Offline Translator\n"
                              "• 📚 Offline Wikipedia (Medical + Survival Data)\n"
                              "• 🚀 NASA Comic Library (Offline)\n\n"
                              "Built for extreme situations — pandemics, disasters, or total offline environments.\n"
                              "This app helps you think, decide, and survive.\n\n"
                              "Because when everything fails...\nLast Hope remains.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(_colorAnimation.value),
                            fontSize: screenWidth * 0.035,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeSliderScreen(),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter:
                            ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.09,
                                vertical: screenHeight * 0.015,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                color: Colors.white.withOpacity(0.08),
                              ),
                              child: Text(
                                "Jump to Actions",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Image.asset(
                                    'assets/images/earth_gif.webp',
                                    width: screenWidth * 0.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Image.asset(
                                    'assets/images/earth_gif.webp',
                                    width: screenWidth * 0.08,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Your Privacy Policy Content Here",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "About Last Hope App",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}