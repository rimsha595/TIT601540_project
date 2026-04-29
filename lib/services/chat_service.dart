import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // 🧠 CREATE OR GET CHAT ID
  String getChatId(String otherUserId) {
    List ids = [uid, otherUserId];
    ids.sort();
    return ids.join("_");
  }

  // 💬 SEND MESSAGE
  Future<void> sendMessage(String chatId, String message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'users': FieldValue.arrayUnion([uid]),
    }, SetOptions(merge: true));
  }

  // 📩 GET MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
