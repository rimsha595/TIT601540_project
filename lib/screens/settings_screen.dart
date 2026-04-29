import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool pushNotifications = true;
  bool messageAlerts = true;
  bool onlineStatus = true;
  String roomAccess = "Everyone";

  @override
  void initState() {
    super.initState();
    loadSettings();
    initFCM();
    setOnline(true);
  }

  // 🔥 FCM INIT
  Future<void> initFCM() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null && user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .set({"fcmToken": token}, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // 🔥 ONLINE STATUS
  Future<void> setOnline(bool status) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
      "onlineStatus": status,
      "lastSeen": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 🔥 LOAD SETTINGS
  Future<void> loadSettings() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      pushNotifications = data['pushNotifications'] ?? true;
      messageAlerts = data['messageAlerts'] ?? true;
      onlineStatus = data['onlineStatus'] ?? true;
      roomAccess = data['roomAccess'] ?? "Everyone";
    });
  }

  // 🔥 SAVE SETTINGS
  Future<void> saveSettings() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      "pushNotifications": pushNotifications,
      "messageAlerts": messageAlerts,
      "onlineStatus": onlineStatus,
      "roomAccess": roomAccess,
    }, SetOptions(merge: true));

    if (pushNotifications) {
      await FirebaseMessaging.instance.subscribeToTopic("allUsers");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("allUsers");
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings Updated")),
    );
  }

  // 🔥 DELETE ACCOUNT (FULL SAFE VERSION)
  Future<void> deleteAccount() async {
    try {
      if (user == null) return;

      String uid = user!.uid;

      // 1. delete firestore user data
      await FirebaseFirestore.instance.collection("users").doc(uid).delete();

      // 2. delete auth user
      await user!.delete();

      if (!mounted) return;

      // 3. go to login screen and remove all routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please login again to delete account"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    setOnline(false);
    super.dispose();
  }

  // UI
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget switchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return SwitchListTile(
      secondary: icon != null ? Icon(icon, color: Colors.white) : null,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: (val) {
        setState(() => onChanged(val));
        saveSettings();
      },
      activeColor: Colors.white,
    );
  }

  void changeRoomAccess() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ["Everyone", "Friends Only", "Invite Only"]
            .map(
              (option) => ListTile(
                title:
                    Text(option, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => roomAccess = option);
                  Navigator.pop(context);
                  saveSettings();
                },
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          sectionTitle("Notifications"),
          switchTile(
            title: "Push Notifications",
            value: pushNotifications,
            icon: Icons.notifications,
            onChanged: (val) => pushNotifications = val,
          ),
          switchTile(
            title: "Message Alerts",
            value: messageAlerts,
            icon: Icons.message,
            onChanged: (val) => messageAlerts = val,
          ),
          sectionTitle("Privacy"),
          switchTile(
            title: "Online Status",
            value: onlineStatus,
            icon: Icons.circle,
            onChanged: (val) => onlineStatus = val,
          ),
          ListTile(
            title: const Text("Who can join room",
                style: TextStyle(color: Colors.white)),
            trailing:
                Text(roomAccess, style: const TextStyle(color: Colors.grey)),
            onTap: changeRoomAccess,
          ),
          sectionTitle("Account"),
          ListTile(
            title: const Text("Change Password",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Delete Account",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Account"),
                  content:
                      const Text("This action is permanent. Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteAccount();
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
