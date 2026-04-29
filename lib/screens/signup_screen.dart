import 'package:flutter/material.dart';
import '../widgets/animated_title.dart';
import 'avatar_screen.dart';
import '../utils/validators.dart';
import '../utils/responsive.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  DateTime? selectedDate;

  bool isLoading = false;
  bool hidePassword = true;

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> handleSignup() async {
    if (isLoading) return;

    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        selectedDate == null) {
      showMessage("Please fill all fields");
      return;
    }

    if (!Validators.isValidEmail(email)) {
      showMessage("Invalid email format");
      return;
    }

    if (!Validators.isStrongPassword(password)) {
      showMessage("Password must be 8+ chars with letters & numbers");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.signup(
        name,
        username,
        email,
        password,
        selectedDate!,
      );

      if (!mounted) return;

      if (user != null) {
        showMessage("Signup successful 🎉");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AvatarScreen()),
        );
      } else {
        showMessage("Signup failed (user null)");
      }
    } catch (e) {
      final error = e.toString();

      if (error.contains("USERNAME_TAKEN")) {
        showMessage("Username already taken");
      } else if (error.contains("email-already-in-use")) {
        showMessage("Email already in use");
      } else if (error.contains("WEAK_PASSWORD")) {
        showMessage("Weak password");
      } else if (error.contains("INVALID_EMAIL")) {
        showMessage("Invalid email");
      } else {
        showMessage("Something went wrong");
      }

      debugPrint("🔥 SIGNUP ERROR: $error");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _field(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = Responsive.width(context);

    return Scaffold(
      backgroundColor: Colors.black,
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: width > 600 ? 420 : width * 0.9,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  const Hero(
                    tag: "appTitle",
                    child: AnimatedTitle(),
                  ),

                  const SizedBox(height: 20),

                  _field("Full Name", Icons.person, nameController),
                  const SizedBox(height: 15),
                  _field("Username", Icons.alternate_email, usernameController),
                  const SizedBox(height: 15),
                  _field("Email", Icons.email, emailController),
                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white70),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate == null
                                ? "Select Date of Birth"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.cyanAccent)
                      : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: handleSignup,
                            child: const Text("SIGN UP"),
                          ),
                        ),

                  const SizedBox(height: 15),

                  // ✅ LOGIN LINK (ADDED)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
