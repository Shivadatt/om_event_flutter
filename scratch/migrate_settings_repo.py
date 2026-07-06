import os
import re

source_path = r"d:\om_event_python\om_event\lib\data\repositories\settings_repository_impl.dart"
dest_path = r"d:\om_event_python\om_event\lib\data\repositories\supabase_settings_repository.dart"

with open(source_path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Imports Update
code = code.replace(
    "import 'package:cloud_firestore/cloud_firestore.dart';",
    "import 'package:supabase_flutter/supabase_flutter.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'dart:async';"
)

# 2. Class Name Update
code = code.replace(
    "class SettingsRepositoryImpl implements SettingsRepository {",
    "class SupabaseSettingsRepository implements SettingsRepository {"
)

# 3. Firestore instance to SupabaseClient update
code = code.replace(
    "final FirebaseFirestore _firestore = FirebaseFirestore.instance;",
    "final SupabaseClient _client = Supabase.instance.client;\n\n  Stream<Map<String, dynamic>> _streamDoc(String docId) {\n    return _client\n        .from('settings')\n        .stream(primaryKey: ['id'])\n        .eq('id', docId)\n        .map((rows) => rows.isNotEmpty ? rows.first : {});\n  }"
)

# 4. Replace Firestore streams with _streamDoc stream
# Pattern:
#     return _firestore
#         .collection(AppCollections.settings)
#         .doc('business')
#         .snapshots()
#         .map((doc) {
#           if (!doc.exists) return ...;
#           final data = doc.data()!;
#           final source = data['published'] ?? data['draft'] ?? {};
#
# Replace with:
#     return _streamDoc('business')
#         .map((data) {
#           if (data.isEmpty) return ...;
#           final source = data['published'] ?? data['draft'] ?? {};

# Replace firestore streams recursively or via regex
# We can match:
# _firestore\s*\.\s*collection\(AppCollections\.settings\)\s*\.\s*doc\('(\w+)'\)\s*\.\s*snapshots\(\)
code = re.sub(
    r"_firestore\s*\.\s*collection\(AppCollections\.settings\)\s*\.\s*doc\('(\w+)'\)\s*\.\s*snapshots\(\)",
    r"_streamDoc('\1')",
    code
)

# Replace doc check logic:
# if (!doc.exists)
code = code.replace("if (!doc.exists)", "if (data.isEmpty)")
# final data = doc.data()!;
code = code.replace("final data = doc.data()!;", "// data is already Map")

# 5. Overwrite the saveToDraft and publish/rollback/history methods at the end of the file
# We will find the start of `_saveToDraft` method and replace everything from there to the end of the file.

end_part = """  Future<void> _saveToDraft(
    String docId,
    Map<String, dynamic> draftData,
  ) async {
    final snap = await _client.from('settings').select('meta').eq('id', docId).maybeSingle();
    final currentMeta = snap != null ? (snap['meta'] as Map<String, dynamic>? ?? {}) : {};

    final payload = {
      'id': docId,
      'key': docId,
      'draft': draftData,
      'published': draftData,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    };
    await _client.from('settings').upsert(payload);
  }

  // Publish / Rollback
  @override
  Future<void> publishSettings(String docId) async {
    final snap = await _client.from('settings').select().eq('id', docId).maybeSingle();
    if (snap == null) return;

    final draft = snap['draft'];
    final meta = snap['meta'] as Map<String, dynamic>? ?? {};

    final currentVersion = (meta['version'] ?? 1) as int;
    final newVersion = currentVersion + 1;
    final now = DateTime.now().toIso8601String();

    await _client.from('settings_history').insert({
      'setting_id': docId,
      'version': currentVersion,
      'published': snap['published'] ?? draft,
      'meta': meta,
    });

    await _client.from('settings').update({
      'published': draft,
      'meta': {
        ...meta,
        'version': newVersion,
        'updated_at': now,
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }).eq('id', docId);

    await _client.from('activity_logs').insert({
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'action': 'Publish',
      'entity_type': 'settings',
      'entity_id': docId,
      'ip_address': 'CMS Web Console',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVersionHistory(String docId) async {
    final response = await _client
        .from('settings_history')
        .select()
        .eq('setting_id', docId)
        .order('version', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> rollbackToVersion(String docId, int version) async {
    final historyDoc = await _client
        .from('settings_history')
        .select()
        .eq('setting_id', docId)
        .eq('version', version)
        .maybeSingle();
    if (historyDoc == null) return;

    final publishedVal = historyDoc['published'];
    final meta = historyDoc['meta'] as Map<String, dynamic>? ?? {};
    final now = DateTime.now().toIso8601String();

    await _client.from('settings').upsert({
      'id': docId,
      'key': docId,
      'draft': publishedVal,
      'published': publishedVal,
      'meta': {
        ...meta,
        'updated_at': now,
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });
  }
}
"""

# Find `Future<void> _saveToDraft` index and chop off the end of file
index = code.find("Future<void> _saveToDraft")
if index != -1:
    code = code[:index] + end_part
else:
    print("Warning: _saveToDraft not found")

with open(dest_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Migration of settings repository completed successfully!")
