import 'package:flutter/material.dart';
import '../services/room_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final RoomService _roomService = RoomService();

  String roomType = "Public";
  double maxUsers = 8;
  String? roomCode;

  bool isLoading = false;
  String error = "";

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> createRoom() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() => error = "Room name cannot be empty");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
      roomCode = null;
    });

    try {
      String? code = await _roomService.createRoom(
        name,
        maxUsers.toInt(),
      );

      setState(() {
        roomCode = code;
        if (code == null) error = "Failed to create room (Firebase issue)";
      });
    } catch (e) {
      setState(() => error = "Error: $e");
    }

    setState(() => isLoading = false);
  }

  Widget toggleButton(String text) {
    bool selected = roomType == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => roomType = text),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
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
          "Create Room",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          // 🔥 HERO ONLY ON FORM AREA (NOT FULL SCREEN)
          child: Hero(
            tag: "create_room",
            child: Material(
              color: Colors.transparent,
              child: ListView(
                children: [
                  const Text("ROOM NAME", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Enter room name..."),
                  ),
                  const SizedBox(height: 15),
                  const Text("DESCRIPTION",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Optional description..."),
                  ),
                  const SizedBox(height: 15),
                  const Text("ROOM TYPE", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      toggleButton("Public"),
                      const SizedBox(width: 10),
                      toggleButton("Private"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("MAX USERS", style: TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (maxUsers > 1) setState(() => maxUsers--);
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: maxUsers,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: maxUsers.toInt().toString(),
                          onChanged: (val) => setState(() => maxUsers = val),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (maxUsers < 20) setState(() => maxUsers++);
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Selected: ${maxUsers.toInt()}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (error.isNotEmpty)
                    Text(error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : createRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("CREATE ROOM"),
                    ),
                  ),
                  if (roomCode != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Room Code: $roomCode",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
