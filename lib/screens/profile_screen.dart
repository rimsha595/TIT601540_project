import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'avatar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService auth = AuthService();
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 SAME FIREBASE LOGIC (UNCHANGED)
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<int> friendsCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> roomsCount() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> chatsCount() {
    return FirebaseFirestore.instance
        .collection('chat')
        .where('users', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // 🔥 GLASS UI (NO LOGIC CHANGE)
  Widget glass(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget stat(String value, String label, IconData icon) {
    return Expanded(
      child: glass(
        Column(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          final isOnline = data?['isOnline'] ?? false;
          final avatarIndex = data?['avatar'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 CLEAN HEADER (SAFE + SMALL)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 50, bottom: 25, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A00E0),
                        Color(0xFF8E2DE2),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white24,
                          child: avatarIndex == null
                              ? const Icon(Icons.person,
                                  size: 38, color: Colors.white)
                              : Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Colors.primaries[
                                      avatarIndex % Colors.primaries.length],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _fade,
                        child: Text(
                          data?['name'] ?? "User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "@${data?['username'] ?? ""}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle,
                              size: 8,
                              color: isOnline
                                  ? Colors.greenAccent
                                  : Colors.redAccent),
                          const SizedBox(width: 5),
                          Text(
                            isOnline ? "Online" : "Offline",
                            style: TextStyle(
                              color: isOnline
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 STATS (FIREBASE SAFE)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      StreamBuilder<int>(
                        stream: roomsCount(),
                        builder: (_, s) =>
                            stat("${s.data ?? 0}", "Rooms", Icons.meeting_room),
                      ),
                      const SizedBox(width: 10),
                      StreamBuilder<int>(
                        stream: friendsCount(),
                        builder: (_, s) =>
                            stat("${s.data ?? 0}", "Friends", Icons.people),
                      ),
                      const SizedBox(width: 10),
                      StreamBuilder<int>(
                        stream: chatsCount(),
                        builder: (_, s) =>
                            stat("${s.data ?? 0}", "Chats", Icons.chat),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 MENU (UNCHANGED LOGIC)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: glass(
                    Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.white),
                          title: const Text("Edit Profile",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  name: data?['name'] ?? "",
                                  username: data?['username'] ?? "",
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.white12),
                        ListTile(
                          leading:
                              const Icon(Icons.person, color: Colors.white),
                          title: const Text("Change Avatar",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AvatarScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 LOGOUT (UNCHANGED)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await auth.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
