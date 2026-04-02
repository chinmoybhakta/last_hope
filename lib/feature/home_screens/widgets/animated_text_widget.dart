import 'package:flutter/material.dart';

class SurvivorAIText extends StatefulWidget {
  final List<String> texts;
  final double fontSize;

  const SurvivorAIText({
    super.key,
    required this.texts,
    this.fontSize = 16,
  });

  @override
  State<SurvivorAIText> createState() => _SurvivorAITextState();
}

class _SurvivorAITextState extends State<SurvivorAIText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _startLoop();
  }

  void _startLoop() async {
    while (mounted) {
      await _controller.forward();
      await Future.delayed(const Duration(seconds: 2));

      await _controller.reverse();

      setState(() {
        currentIndex = (currentIndex + 1) % widget.texts.length;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scaleText(double size) =>
        size * MediaQuery.of(context).textScaleFactor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Text(
          widget.texts[currentIndex],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: scaleText(widget.fontSize),
            color: Colors.white,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}