// ignore_for_file: avoid_web_libraries_in_flutter, avoid_web_libraries_in_dart, deprecated_member_use
import 'dart:html' as html;

Future<void> saveAndLaunchPdfImpl(List<int> bytes, String fileName) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
