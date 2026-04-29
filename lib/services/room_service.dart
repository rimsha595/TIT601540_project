import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 SAFE UID
  String? get uid => _auth.currentUser?.uid;

  // =========================
  // 🔥 CREATE ROOM (FIXED)
  // =========================
  Future<String?> createRoom(String roomName, int maxUsers) async {
    try {
      if (uid == null) {
        print("❌ User not logged in");
        return null;
      }

      String roomId = _generateRoomCode();

      print("🚀 Creating room: $roomId");

      await _firestore.collection('rooms').doc(roomId).set({
        'roomName': roomName,
        'hostId': uid,
        'participants': [uid],
        'maxUsers': maxUsers,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Room created successfully");

      return roomId;
    } catch (e) {
      print("❌ Create Room Error: $e");
      return null;
    }
  }

  // =========================
  // 🔥 JOIN ROOM (SAFE + FIXED)
  // =========================
  Future<bool> joinRoom(String roomId) async {
    try {
      if (uid == null) return false;

      DocumentReference roomRef = _firestore.collection('rooms').doc(roomId);

      DocumentSnapshot roomSnap = await roomRef.get();

      if (!roomSnap.exists) {
        print("❌ Room not found");
        return false;
      }

      Map<String, dynamic> data = roomSnap.data() as Map<String, dynamic>;

      List participants = List.from(data['participants'] ?? []);

      int maxUsers = data['maxUsers'] ?? 0;

      // 🚫 FULL CHECK
      if (participants.length >= maxUsers) {
        print("❌ Room is full");
        return false;
      }

      // 🚫 ALREADY JOINED
      if (participants.contains(uid)) {
        print("⚠ Already joined");
        return true;
      }

      participants.add(uid);

      await roomRef.update({
        'participants': participants,
      });

      print("✅ Joined room successfully");

      return true;
    } catch (e) {
      print("❌ Join Room Error: $e");
      return false;
    }
  }

  // =========================
  // 🔥 RECENT ROOMS (FIXED QUERY)
  // =========================
  Stream<List<Map<String, dynamic>>> getRecentRooms() {
    if (uid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('rooms')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          "id": doc.id,
          "roomName": data['roomName'] ?? '',
          "createdAt": data['createdAt'],
        };
      }).toList()
        ..sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;

          if (aTime == null || bTime == null) return 0;

          return bTime.compareTo(aTime);
        });
    });
  }

  // =========================
  // 🔥 ROOM CODE GENERATOR
  // =========================
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }
}
