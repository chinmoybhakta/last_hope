import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_button_widget.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_text_widget.dart';

class NasaScreen extends StatefulWidget {
  const NasaScreen({super.key});

  @override
  State<NasaScreen> createState() => _NasaScreenState();
}

class _NasaScreenState extends State<NasaScreen> {
  bool isHovered = false;

  double scaleWidth(double width, BuildContext context) =>
      width * MediaQuery.of(context).size.width / 430;
  double scaleHeight(double height, BuildContext context) =>
      height * MediaQuery.of(context).size.height / 932;
  double scaleText(double size, BuildContext context) =>
      size * MediaQuery.of(context).textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/fth.webp',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      top: scaleHeight(20, context),
                      left: 0,
                      right: 0,
                      child: Center(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isHovered
                                ? scaleWidth(420, context)
                                : scaleWidth(380, context),
                            height: isHovered
                                ? scaleHeight(410, context)
                                : scaleHeight(370, context),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(
                                    isHovered ? 0.25 : 0.12,
                                  ),
                                  blurRadius: isHovered
                                      ? scaleWidth(25, context)
                                      : scaleWidth(12, context),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: scaleHeight(10, context)),
                                Text(
                                  'NASA BOOKS',
                                  style: TextStyle(
                                    fontSize: scaleText(40, context),
                                    fontFamily: 'Cursive',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFA6A6FF),
                                  ),
                                ),
                                SizedBox(height: scaleHeight(40, context)),
                                PulsingAIImage(
                                  imagePath: 'assets/images/stack-of-books.png',
                                  shadowColor: Colors.blueAccent,
                                  size: 100,
                                ),
                                SizedBox(height: scaleHeight(60, context)),
                                SurvivorAIText(
                                  texts: [
                                    "🚀 Explore NASA’s offline comic books for fun space learning",
                                    "🌌 Discover planets, stars, and cosmic mysteries visually",
                                    "📖 Engaging stories that explain science, tech, and astronomy",
                                    "🛸 Learn space knowledge anytime, without internet",
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}