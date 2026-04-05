import 'dart:ui';
import 'package:flutter/material.dart';

class PulsingAIImage extends StatefulWidget {
  final String imagePath;
  final Color shadowColor;
  final double size;

  final Widget? nextScreen;

  const PulsingAIImage({
    super.key,
    required this.imagePath,
    this.shadowColor = Colors.blueAccent,
    this.size = 100,
    this.nextScreen,
  });

  @override
  State<PulsingAIImage> createState() => _PulsingAIImageState();
}

class _PulsingAIImageState extends State<PulsingAIImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleTap() {
    if (widget.nextScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget.nextScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double scaleWidth(double width) =>
        width * MediaQuery.of(context).size.width / 430;

    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: handleTap,
              child: Container(
                padding: EdgeInsets.all(scaleWidth(20)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor.withOpacity(0.25),
                      blurRadius: scaleWidth(20),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Image.asset(
                      widget.imagePath,
                      width: scaleWidth(widget.size),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}