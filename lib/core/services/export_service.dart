import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ExportService {
  ExportService._();

  static Future<void> exportToCsv({
    required String filename,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final csvBuffer = StringBuffer();

    // Headers
    csvBuffer.writeln(headers.join(','));

    // Rows
    for (final row in rows) {
      final sanitizedRow = row.map((cell) {
        final cellStr = cell?.toString() ?? '';
        // Escape quotes
        if (cellStr.contains(',') || cellStr.contains('"') || cellStr.contains('\n')) {
          return '"${cellStr.replaceAll('"', '""')}"';
        }
        return cellStr;
      }).join(',');
      csvBuffer.writeln(sanitizedRow);
    }

    final csvContent = csvBuffer.toString();
    final bytes = utf8.encode(csvContent);
    final base64Content = base64.encode(bytes);
    
    final uri = Uri.parse('data:text/csv;base64,$base64Content');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not trigger CSV download for $filename';
    }
  }
}
