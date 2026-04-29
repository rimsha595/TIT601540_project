import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import '../utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final AuthService _authService = AuthService();

  int selectedAvatar = -1;
  bool isLoading = false;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> saveAvatar() async {
    if (uid == null) return;

    setState(() => isLoading = true);

    try {
      await _authService.saveAvatar(uid!, selectedAvatar);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save avatar")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = Responsive.width(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Avatar"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Choose Your Avatar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width < 600 ? 2 : 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final isSelected = selectedAvatar == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatar = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.cyanAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.person,
                        size: isSelected ? 60 : 50,
                        color: isSelected ? Colors.cyanAccent : Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      selectedAvatar == -1 || isLoading ? null : saveAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
