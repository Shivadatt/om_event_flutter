import 'package:cloud_firestore/cloud_firestore.dart';

class DateParser {
  static DateTime parse(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    try {
      if (value is Map) {
        final sec = value['_seconds'] ?? value['seconds'];
        if (sec is num) {
          return DateTime.fromMillisecondsSinceEpoch((sec * 1000).toInt(), isUtc: true);
        }
      }
      final dyn = value as dynamic;
      final res = dyn.toDate();
      if (res is DateTime) return res;
    } catch (_) {}

    return DateTime.now();
  }

  static DateTime? parseNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();

    if (value is String) {
      return DateTime.tryParse(value);
    }

    try {
      if (value is Map) {
        final sec = value['_seconds'] ?? value['seconds'];
        if (sec is num) {
          return DateTime.fromMillisecondsSinceEpoch((sec * 1000).toInt(), isUtc: true);
        }
      }
      final dyn = value as dynamic;
      final res = dyn.toDate();
      if (res is DateTime) return res;
    } catch (_) {}

    return null;
  }
}
