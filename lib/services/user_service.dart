import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔎 SEARCH BY NAME OR USERNAME
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    QuerySnapshot snap = await _firestore.collection('users').get();

    return snap.docs.map((e) => e.data() as Map<String, dynamic>).where((user) {
      final name = user['name'].toString().toLowerCase();
      final username = user['username'].toString().toLowerCase();

      return name.contains(query.toLowerCase()) ||
          username.contains(query.toLowerCase());
    }).toList();
  }

  // 👥 FRIENDS LIST STREAM
  Stream<List<Map<String, dynamic>>> getFriendsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .asyncMap((snap) async {
      List<Map<String, dynamic>> friends = [];

      for (var doc in snap.docs) {
        var user = await _firestore.collection('users').doc(doc.id).get();
        if (user.exists) {
          friends.add(user.data()!);
        }
      }
      return friends;
    });
  }
}
