/// Helper class to map database schemas between Supabase (snake_case)
/// and Dart models (camelCase) automatically.
class SupabaseMapper {
  SupabaseMapper._();

  /// Converts a snake_case key string to camelCase.
  static String _snakeToCamelKey(String key) {
    if (!key.contains('_')) return key;
    final parts = key.split('_');
    final buffer = StringBuffer(parts[0]);
    for (int i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;
      buffer.write(part[0].toUpperCase() + part.substring(1));
    }
    return buffer.toString();
  }

  /// Recursively transforms a map's keys from snake_case to camelCase.
  static Map<String, dynamic> toCamelCase(Map<String, dynamic> json) {
    final Map<String, dynamic> result = {};
    json.forEach((key, value) {
      final camelKey = _snakeToCamelKey(key);
      if (value is Map<String, dynamic>) {
        result[camelKey] = toCamelCase(value);
      } else if (value is List) {
        result[camelKey] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return toCamelCase(item);
          }
          return item;
        }).toList();
      } else {
        result[camelKey] = value;
      }
    });
    return result;
  }

  /// Converts a camelCase key string to snake_case.
  static String _camelToSnakeKey(String key) {
    final exp = RegExp(r'(?<=[a-z0-9])([A-Z])');
    return key.replaceAllMapped(exp, (Match m) => '_${m.group(0)!}').toLowerCase();
  }

  /// Recursively transforms a map's keys from camelCase to snake_case.
  static Map<String, dynamic> toSnakeCase(Map<String, dynamic> json) {
    final Map<String, dynamic> result = {};
    json.forEach((key, value) {
      final snakeKey = _camelToSnakeKey(key);
      if (value is Map<String, dynamic>) {
        result[snakeKey] = toSnakeCase(value);
      } else if (value is List) {
        result[snakeKey] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return toSnakeCase(item);
          }
          return item;
        }).toList();
      } else {
        result[snakeKey] = value;
      }
    });
    return result;
  }
}
