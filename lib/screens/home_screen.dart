import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/room_service.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import '../widgets/hero_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoomService _roomService = RoomService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = "User";
  bool isLoadingName = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();

      setState(() {
        username = userDoc["name"] ?? "User";
        isLoadingName = false;
      });
    } catch (e) {
      setState(() => isLoadingName = false);
    }
  }

  void navigate(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: screen,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              isLoadingName
                  ? const CircularProgressIndicator()
                  : Text(
                      "Welcome, $username",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

              const SizedBox(height: 25),

              // ================= HERO ACTIONS =================
              Row(
                children: [
                  Expanded(
                    child: HeroActionCard(
                      tag: "create_room",
                      title: "Create Room",
                      subtitle: "Start a new space",
                      icon: Icons.grid_view_rounded,
                      gradient: [Colors.blue, Colors.purple],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 700),
                            pageBuilder: (_, __, ___) =>
                                const CreateRoomScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HeroActionCard(
                      tag: "join_room",
                      title: "Join Room",
                      subtitle: "Enter with code",
                      icon: Icons.login,
                      gradient: [Colors.green, Colors.teal],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 700),
                            pageBuilder: (_, __, ___) => const JoinRoomScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Active Rooms",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: StreamBuilder(
                  stream: _roomService.getRecentRooms(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final rooms = snapshot.data!;

                    return ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];

                        return Card(
                          color: const Color(0xFF1C1C1C),
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Icon(Icons.meeting_room,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    room["roomName"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const JoinRoomScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text("Join"),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
