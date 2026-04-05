import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_button_widget.dart';
import 'package:last_hope/feature/home_screens/widgets/animated_text_widget.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
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
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/shouro_2t.webp',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: scaleHeight(20, context),
                      left: scaleWidth(20, context),
                      child: SizedBox(
                        width: scaleWidth(70, context),
                        height: scaleWidth(70, context),
                        child: Opacity(opacity: 0.3,child: Image.asset(
                          'assets/images/groh.webp',
                          width: 10,
                        ),)
                      ),
                    ),
                    Positioned(
                      top: scaleHeight(100, context),
                      left: scaleWidth(20, context),
                      child: SizedBox(
                        width: scaleWidth(150, context),
                        height: scaleWidth(150, context),
                        child: Opacity(opacity: 0.2,child: Image.asset(
                          'assets/images/groh.webp',
                          width: 30,
                        ),)
                      ),
                    ),
                    Positioned(
                      bottom: scaleHeight(50, context),
                      right: scaleWidth(05, context),
                      child: SizedBox(
                        width: scaleWidth(200, context),
                        height: scaleWidth(200, context),
                        child: Opacity(opacity: 0.7,child: Image.asset(
                          'assets/images/groh.webp',
                          width: 60,
                        ),)
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
                                ? scaleHeight(400, context)
                                : scaleHeight(350, context),
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
                                  'OFFLINE TRANSLATOR',
                                  style: TextStyle(
                                    fontSize: scaleText(30, context),
                                    fontFamily: 'Cursive',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                                SizedBox(height: scaleHeight(40, context)),
                                PulsingAIImage(
                                  imagePath: 'assets/images/translator_icon.png',
                                  shadowColor: Colors.blueAccent,
                                  size: 100,
                                //  nextScreen: MultiLangTranslatorPage,
                                ),
                                SizedBox(height: scaleHeight(40, context)),
                                SurvivorAIText(
                                  texts: [
                                    "🌐 Translate English, বাংলা, हिन्दी, Deutsch & Français offline",
                                    "🗣️ Communicate seamlessly across 5 major languages",
                                    "📖 Understand text and speech in multiple languages instantly",
                                    "🌍 Break language barriers anywhere without internet",
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