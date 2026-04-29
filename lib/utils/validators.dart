class Validators {
  // 📧 EMAIL CHECK
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  // 🔒 PASSWORD STRENGTH
  static bool isStrongPassword(String password) {
    // min 8 chars, 1 letter, 1 number
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }
}
