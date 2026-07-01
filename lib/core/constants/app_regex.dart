/// Centralized validation regex pattern constants.
class AppRegex {
  AppRegex._();

  /// Valid Indian mobile phone number (10 digits, starting 6–9).
  static final RegExp phone = RegExp(r'^[6-9]\d{9}$');

  /// Standard email address pattern.
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// URL starting with http or https.
  static final RegExp url = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// URL-safe slug (lowercase letters, digits, hyphens only).
  static final RegExp slug = RegExp(r'^[a-z0-9-]+$');

  /// Hex color code including the '#' prefix.
  static final RegExp hexColor = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
}
