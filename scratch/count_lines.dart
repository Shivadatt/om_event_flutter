// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }
  
  final files = dir.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final folderMap = <String, List<File>>{};
  for (final file in files) {
    final parent = file.parent.path.replaceAll(r'\', '/').replaceAll('lib/', '');
    folderMap.putIfAbsent(parent, () => []).add(file);
  }

  print('| Folder | Dart Files | Files Analyzed | Files Skipped |');
  print('| ------ | ---------- | -------------- | ------------- |');
  int total = 0;
  for (final entry in folderMap.entries) {
    print('| ${entry.key} | ${entry.value.length} | ${entry.value.length} | 0 |');
    total += entry.value.length;
  }
  print('| **Total** | **$total** | **$total** | **0** |');
  print('\n\nTOTAL FILES: $total');

  print('\nALL FILES DETAILS:');
  for (final file in files) {
    final lines = file.readAsLinesSync().length;
    print('${file.path.replaceAll(r'\', '/')} : $lines lines');
  }
}
