import 'package:flutter/material.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;

  const PremiumButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.94),
      onTapUp: (_) => setState(() => scale = 1),
      onTapCancel: () => setState(() => scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.7),
                blurRadius: 30,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
