import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String? photoUrl;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.username,
    this.photoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  XFile? imageFile;
  Uint8List? imageBytes;

  bool loading = false;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    usernameController.text = widget.username;
  }

  // 📸 PICK IMAGE
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        imageFile = picked;
        imageBytes = bytes;
      });
    }
  }

  // ☁️ UPLOAD IMAGE
  Future<String?> uploadImage() async {
    if (imageBytes == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("$uid.jpg");

    await ref.putData(imageBytes!);

    return await ref.getDownloadURL();
  }

  // 💾 UPDATE PROFILE
  Future<void> updateProfile() async {
    setState(() => loading = true);

    try {
      String? photoUrl = await uploadImage();

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "name": nameController.text.trim(),
        "username": usernameController.text.trim(),
        if (photoUrl != null) "photoUrl": photoUrl,
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  void showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔥 PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,

                    // ✅ IMAGE LOGIC FIXED
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes!) as ImageProvider<Object>
                        : (widget.photoUrl != null
                            ? NetworkImage(widget.photoUrl!)
                                as ImageProvider<Object>
                            : null),

                    child: (imageBytes == null && widget.photoUrl == null)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: showPicker,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // USERNAME
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Username",
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
