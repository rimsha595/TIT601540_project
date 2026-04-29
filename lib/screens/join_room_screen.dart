import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/room_service.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController codeController = TextEditingController();
  final RoomService _roomService = RoomService();

  String message = "";
  bool isJoining = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> joinRoom(String roomId) async {
    if (roomId.isEmpty) {
      setState(() => message = "Please enter Room ID");
      return;
    }

    setState(() {
      isJoining = true;
      message = "";
    });

    bool joined = await _roomService.joinRoom(roomId);

    setState(() {
      isJoining = false;
      message = joined ? "Joined Successfully" : "Room Not Found";
    });
  }

  String timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";

    DateTime time = timestamp.toDate();
    Duration diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Join Room",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // 🔥 SLIVER START
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("ROOM ID", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                    hintText: "Enter Room ID...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isJoining
                        ? null
                        : () => joinRoom(codeController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isJoining
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("JOIN ROOM"),
                  ),
                ),
                const SizedBox(height: 10),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 25),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or pick recent",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "RECENT ROOMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ]),
            ),
          ),

          // 🔥 LIST PART (SLIVER LIST)
          StreamBuilder(
            stream: _roomService.getRecentRooms(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final rooms = snapshot.data!;

              if (rooms.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No recent rooms yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = rooms[index];

                    return GestureDetector(
                      onTap: () => joinRoom(room["id"]),
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 10, left: 20, right: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child:
                                  Icon(Icons.meeting_room, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room["roomName"] ?? "",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeAgo(room["createdAt"]),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: rooms.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
