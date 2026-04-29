import 'package:flutter/material.dart';

class AnimatedTitle extends StatefulWidget {
  const AnimatedTitle({super.key});

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    slide = Tween<Offset>(
      begin: const Offset(0, -0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: Center(
          child: Text(
            "Link3D",
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,

              // ✅ FORCE COLOR (fix black issue)
              color: Colors.cyanAccent,

              // 🔥 Neon Glow Effect
              shadows: const [
                Shadow(
                  blurRadius: 10,
                  color: Colors.cyanAccent,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 25,
                  color: Colors.cyanAccent,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 50,
                  color: Colors.blueAccent,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 80,
                  color: Colors.blue,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
