import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final TabBar? bottom; // 🔥 NEW: TabBar support

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = true,
    this.onNotificationTap,
    this.bottom, // 🔥 added
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,

      // 🔥 TITLE
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
        ).createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),

      // 🔥 BACKGROUND
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),

      // 🔔 ICON
      actions: [
        if (showNotification)
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A0A14),
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Colors.white,
              ),
            ),
          ),
      ],

      // 🔥 TABBAR SUPPORT ADDED
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      bottom == null ? 65 : 110, // 🔥 auto adjust height
    );
  }
}
