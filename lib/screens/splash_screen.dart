import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _navigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage("Assets/Logo.png"),
      context,
    );
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3)); // ⏱️ reduced

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 🔥 LIMIT LOGO SIZE (important for desktop)
    final logoSize = math.min(size.width * 0.45, 250.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          // 🌌 PARTICLES (more on desktop)
          ...List.generate(size.width > 600 ? 50 : 20, (index) {
            final random = Random(index);
            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: Container(
                width: random.nextDouble() * 6 + 2,
                height: random.nextDouble() * 6 + 2,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          Center(
            child: SingleChildScrollView(
              // ✅ prevents overflow
              child: FadeTransition(
                opacity: _fadeController,
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset:
                          Offset(0, sin(_floatController.value * pi * 2) * 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // ✅ important fix
                        children: [
                          // 🔵 GLOW LOGO
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.6),
                                  blurRadius: 80,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "Assets/Logo.png",
                              width: logoSize,
                              height: logoSize,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "3D SOCIAL HUB",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white12,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
