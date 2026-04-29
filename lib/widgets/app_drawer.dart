import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/create_room_screen.dart';
import '../screens/join_room_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final TabController tabController;

  const AppDrawer({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFF0F0F1C),
      child: Column(
        children: [
          // 🔥 HEADER
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['name'] ?? "No Name",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['email'] ?? "No Email",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🔥 MENU
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sectionTitle("MAIN"),
                _tile(Icons.home, "Home", 0, context),
                _tile(Icons.people, "Friends", 1, context),
                _tile(Icons.history, "History", 2, context),
                const Divider(color: Colors.white24),
                _sectionTitle("QUICK ACTIONS"),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.white),
                  title: const Text("Create Room",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateRoomScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: const Text("Join Room",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JoinRoomScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white24),
                _sectionTitle("PREFERENCES"),
                _simpleTile(Icons.person, "Avatar Customization"),
                _simpleTile(Icons.volume_up, "Audio Settings"),
                const Divider(color: Colors.white24),
                _sectionTitle("SETTINGS"),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text("Settings",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, int index, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // close drawer

        // 🔥 FIX: proper animation + AppBar sync
        tabController.animateTo(index);
      },
    );
  }

  Widget _simpleTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}
