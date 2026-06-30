class AppValidators {
  static String cleanPhone(String phone) {
    // Strip non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Take the last 10 characters
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static bool isValidPhone(String phone) {
    final cleaned = cleanPhone(phone);
    return cleaned.length == 10;
  }

  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return true; // Optional field
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isFutureDate(DateTime date) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final checkDateOnly = DateTime(date.year, date.month, date.day);
    return !checkDateOnly.isBefore(todayDateOnly);
  }
}
