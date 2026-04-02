import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_button_widget.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_text_widget.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
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
                        child: Image.asset(
                          'assets/images/moon_4.webp',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                    ),
                    SizedBox(height: 50,),
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
                                : scaleHeight(400, context),
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
                                  'OFFLINE WIKIPEDIA',
                                  style: TextStyle(
                                    fontSize: scaleText(30, context),
                                    fontFamily: 'Cursive',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                SizedBox(height: scaleHeight(40, context)),
                                PulsingAIImage(
                                  imagePath: 'assets/images/wiki_icon.png',
                                  shadowColor: Colors.red,
                                  size: 100,
                                ),
                                SizedBox(height: scaleHeight(80, context)),
                                SurvivorAIText(
                                  texts: [
                                    "📚 Access offline Wikipedia for survival and emergency knowledge",
                                    "🩺 Reliable medical references for critical situations",
                                    "🌦️ Learn climate change, weather patterns, and natural risks",
                                    "🔥 Guides on water purification, food preparation, and survival skills",
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