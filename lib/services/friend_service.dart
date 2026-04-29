import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  String get email => FirebaseAuth.instance.currentUser!.email ?? '';

  // =========================
  // 📩 SEND FRIEND REQUEST
  // =========================
  Future<void> sendFriendRequest(String receiverUid) async {
    await _firestore.collection('friend_requests').add({
      'senderId': uid,
      'receiverId': receiverUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 📥 GET REQUESTS
  // =========================
  Stream<QuerySnapshot> getRequests() {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // =========================
  // 👤 GET USER DATA (NAME + USERNAME FIX)
  // =========================
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      var doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // ✅ ACCEPT REQUEST (BIDIRECTIONAL FRIENDS)
  // =========================
  Future<void> acceptRequest(String docId, String senderId) async {
    // add friend for current user
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(senderId)
        .set({
      'uid': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // add friend for sender user
    await _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(uid)
        .set({
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // delete request
    await _firestore.collection('friend_requests').doc(docId).delete();
  }

  // =========================
  // ❌ REJECT REQUEST
  // =========================
  Future<void> rejectRequest(String docId) async {
    await _firestore.collection('friend_requests').doc(docId).delete();
  }

  // =========================
  // 🟢 ONLINE / OFFLINE STATUS
  // =========================
  Future<void> setOnlineStatus(bool status) async {
    await _firestore.collection('users').doc(uid).update({
      'isOnline': status,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 👥 GET FRIENDS STREAM
  // =========================
  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .asyncMap((snap) async {
      List<Map<String, dynamic>> friends = [];

      for (var doc in snap.docs) {
        var userDoc = await _firestore.collection('users').doc(doc.id).get();

        if (userDoc.exists) {
          friends.add(userDoc.data()!);
        }
      }

      return friends;
    });
  }
}
