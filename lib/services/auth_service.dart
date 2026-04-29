import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------------
  // CURRENT USER
  // -------------------------------
  User? get currentUser => _auth.currentUser;

  // -------------------------------
  // VALIDATIONS
  // -------------------------------
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  Future<bool> isUsernameTaken(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // -------------------------------
  // SIGNUP (SAFE + FIXED)
  // -------------------------------
  Future<User?> signup(
    String name,
    String username,
    String email,
    String password,
    DateTime dob,
  ) async {
    try {
      if (!isValidEmail(email)) throw Exception("INVALID_EMAIL");
      if (!isStrongPassword(password)) throw Exception("WEAK_PASSWORD");
      if (await isUsernameTaken(username)) throw Exception("USERNAME_TAKEN");

      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user == null) throw Exception("USER_NULL");

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'username': username,
        'email': email,
        'dob': dob.toIso8601String(),
        'avatar': -1,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print("🔥 SIGNUP AUTH ERROR: ${e.code}");
      throw Exception(e.code);
    } catch (e) {
      print("🔥 SIGNUP ERROR: $e");
      throw Exception(e.toString());
    }
  }

  // -------------------------------
  // LOGIN (SAFE + FIXED)
  // -------------------------------
  Future<User?> login(String email, String password) async {
    try {
      if (!isValidEmail(email)) throw Exception("INVALID_EMAIL");

      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'isOnline': true,
        }, SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("🔥 LOGIN AUTH ERROR: ${e.code}");
      throw Exception(e.code);
    } catch (e) {
      print("🔥 LOGIN ERROR: $e");
      throw Exception("LOGIN_FAILED");
    }
  }

  // -------------------------------
  // LOGOUT (FULLY SAFE)
  // -------------------------------
  Future<void> logout() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'isOnline': false,
        }, SetOptions(merge: true));
      }

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print("🔥 LOGOUT AUTH ERROR: ${e.code}");
      throw Exception(e.code);
    } catch (e) {
      print("🔥 LOGOUT ERROR: $e");
      throw Exception("LOGOUT_FAILED");
    }
  }

  // -------------------------------
  // FORGOT PASSWORD
  // -------------------------------
  Future<void> forgotPassword(String email) async {
    try {
      if (!isValidEmail(email)) throw Exception("INVALID_EMAIL");

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("🔥 RESET ERROR: ${e.code}");
      throw Exception(e.code);
    } catch (e) {
      throw Exception("RESET_FAILED");
    }
  }

  // -------------------------------
  // SAVE AVATAR
  // -------------------------------
  Future<void> saveAvatar(String uid, int avatar) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'avatar': avatar,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("AVATAR_SAVE_FAILED");
    }
  }

  // -------------------------------
  // GET USER DATA
  // -------------------------------
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      return doc.data();
    } catch (e) {
      throw Exception("USER_FETCH_FAILED");
    }
  }

  // -------------------------------
  // UPDATE USER FIELD
  // -------------------------------
  Future<void> updateUserField(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception("UPDATE_FAILED");
    }
  }
}
