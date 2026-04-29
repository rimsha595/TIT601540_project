import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../services/user_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendService _friendService = FriendService();
  final UserService _userService = UserService();

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  // 🔍 SEARCH
  void searchUsers(String value) async {
    if (value.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    var results = await _userService.searchUsers(value);
    setState(() => searchResults = results);
  }

  String getInitial(String? name) {
    if (name == null || name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  // 👤 FRIEND CARD
  Widget friendCard(Map<String, dynamic> user) {
    return ListTile(
      onTap: () {
        String chatId = ChatService().getChatId(user['uid']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              name: user['name'] ?? "Chat",
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(getInitial(user['name'])),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: user['isOnline'] == true ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user['name'] ?? "",
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        user['isOnline'] == true ? "Online" : "Offline",
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }

  // 📩 REQUEST SCREEN
  void openRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0B0F1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0B0F1A),
            title: const Text("Requests"),
          ),
          body: StreamBuilder(
            stream: _friendService.getRequests(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No Requests",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index];

                  return FutureBuilder(
                    future: _friendService.getUserById(data['senderId']),
                    builder: (context, snap) {
                      var user = snap.data;

                      return ListTile(
                        title: Text(
                          user?['name'] ?? "Loading...",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _friendService.acceptRequest(
                                  data.id,
                                  data['senderId'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _friendService.rejectRequest(data.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH (NOW UPPER)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: TextField(
                controller: searchController,
                onChanged: searchUsers,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF1C2233),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🟢 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: openRequests,
                    icon: const Icon(Icons.person_add_alt_1,
                        color: Colors.white, size: 20),
                    label: const Text(
                      "Requests",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 🔎 SEARCH RESULTS OR FRIEND LIST
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView(
                  children: searchResults.map((u) => friendCard(u)).toList(),
                ),
              )
            else
              Expanded(
                child: StreamBuilder(
                  stream: _friendService.getFriendsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var friends = snapshot.data!;

                    var online =
                        friends.where((f) => f['isOnline'] == true).toList();

                    var offline =
                        friends.where((f) => f['isOnline'] != true).toList();

                    return ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "ONLINE",
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        ...online.map((u) => friendCard(u)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white24),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "OFFLINE",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        ...offline.map((u) => friendCard(u)),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
