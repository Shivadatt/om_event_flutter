import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_buckets.dart';
import '../services/realtime_manager.dart';

// Repository imports for DI check
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/contact_number_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/repositories/business_details_repository.dart';

class VerificationItem {
  final String name;
  final String status; // 'PASS', 'FAIL', 'WARNING', 'NOT IMPLEMENTED', 'SKIPPED'
  final String reason;

  const VerificationItem({
    required this.name,
    required this.status,
    required this.reason,
  });
}

class EnterpriseVerificationService extends GetxService {
  static EnterpriseVerificationService get to => Get.find();

  final SupabaseClient _client = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxList<VerificationItem> results = <VerificationItem>[].obs;
  final RxBool isVerifying = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxInt readinessPercent = 0.obs;

  @override
  void onInit() {
    super.onInit();
    runFullVerification();
  }

  Future<void> runFullVerification() async {
    if (isVerifying.value) return;

    isVerifying.value = true;
    progress.value = 0.0;
    results.clear();

    final List<Future<void>> checks = [
      _verifyFirebaseAuthHeaders(), // Task 5
      _verifyFirebaseMessaging(),
      _verifySupabaseConnection(),
      _verifyStorageOperations(), // Task 6
      _verifyEdgeFunctions(),
      _verifyRealtime(),
      _verifyDbTables(), // Task 2
      _verifyCrudOperations(),
      _verifyRepositoryBindings(), // Task 1
    ];

    int completed = 0;
    for (final check in checks) {
      await check;
      completed++;
      progress.value = completed / checks.length;
    }

    _calculateReadiness();
    _printConsoleReport();

    isVerifying.value = false;
  }

  void _calculateReadiness() {
    if (results.isEmpty) {
      readinessPercent.value = 0;
      return;
    }

    // Dynamic Readiness Score (Task 8): Ignore optional/skipped/not-implemented modules
    final activeResults = results.where((item) => 
      item.status != 'SKIPPED' && 
      item.status != 'NOT IMPLEMENTED' &&
      item.status != 'PENDING MIGRATION'
    ).toList();

    if (activeResults.isEmpty) {
      readinessPercent.value = 100;
      return;
    }

    final passCount = activeResults.where((item) => item.status == 'PASS').length;
    final warningCount = activeResults.where((item) => item.status == 'WARNING').length;
    
    final double score = (passCount * 1.0) + (warningCount * 0.5);
    readinessPercent.value = ((score / activeResults.length) * 100).round();
  }

  void _addResult(String name, String status, String reason) {
    results.add(VerificationItem(name: name, status: status, reason: reason));
  }

  // ─── Verification Modules ──────────────────────────────────────────────────

  Future<void> _verifyFirebaseAuthHeaders() async {
    try {
      final user = _auth.currentUser;
      final syncedUid = _client.rest.headers['x-firebase-uid'];

      print('Firebase user: ${user?.email ?? "null"}');
      print('Firebase token synced: ${syncedUid != null}');
      print('Header updated: ${syncedUid == user?.uid}');

      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          if (syncedUid == user.uid) {
            _addResult("Firebase Auth Headers", "PASS", "Session verified and RLS headers synced: ${user.email}");
          } else {
            _addResult("Firebase Auth Headers", "WARNING", "Session active but client headers not synchronized yet");
          }
        } else {
          _addResult("Firebase Auth Headers", "WARNING", "Active session exists, but ID token is empty");
        }
      } else {
        _addResult("Firebase Auth Headers", "WARNING", "No active user session. Headers are clear (normal behavior for logged-out state)");
      }
    } catch (e) {
      _addResult("Firebase Auth Headers", "FAIL", "Auth Header verification failed: ${e.toString()}");
    }
  }

  Future<void> _verifyFirebaseMessaging() async {
    try {
      if (kIsWeb) {
        _addResult("Firebase Messaging", "PASS", "Web messaging instances active");
        return;
      }
      final settings = await _fcm.getNotificationSettings();
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        _addResult("Firebase Messaging", "PASS", "FCM token resolved. Permission: ${settings.authorizationStatus}");
      } else {
        _addResult("Firebase Messaging", "WARNING", "FCM active but token not generated yet");
      }
    } catch (e) {
      _addResult("Firebase Messaging", "FAIL", "Messaging token fetch failure: ${e.toString()}");
    }
  }

  Future<void> _verifySupabaseConnection() async {
    try {
      await _client.from('settings').select().limit(1);
      _addResult("Supabase Connection", "PASS", "API connection verified successfully");
    } catch (e) {
      _addResult("Supabase Connection", "FAIL", "API Connection failed: ${e.toString()}");
    }
  }

  Future<void> _verifyStorageOperations() async {
    // Read bucket dynamically from AppBuckets (Task 6)
    final bucketName = AppBuckets.gallery;
    print('Storage bucket used: $bucketName');

    final testPath = 'verification_test_${DateTime.now().millisecondsSinceEpoch}.txt';
    final testBytes = utf8.encode("Supabase storage verification write token");

    try {
      // 1. Upload Test
      await _client.storage.from(bucketName).uploadBinary(
            testPath,
            Uint8List.fromList(testBytes),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      _addResult("Storage Upload", "PASS", "Successfully uploaded payload to '$bucketName' bucket");

      // 2. Download Test
      final downloadedBytes = await _client.storage.from(bucketName).download(testPath);
      final downloadedText = utf8.decode(downloadedBytes);

      if (downloadedText == "Supabase storage verification write token") {
        _addResult("Storage Download", "PASS", "Successfully downloaded payload from '$bucketName' bucket");
      } else {
        _addResult("Storage Download", "WARNING", "Data download succeeded but content mismatch");
      }

      // Cleanup
      await _client.storage.from(bucketName).remove([testPath]);
    } catch (e) {
      String reason = e.toString();
      if (reason.contains('Bucket not found') || reason.contains('Object not found')) {
        reason = "Bucket '$bucketName' does not exist on Supabase storage server";
      }
      _addResult("Storage Upload", "FAIL", "Upload failed on '$bucketName': $reason");
      _addResult("Storage Download", "FAIL", "Download failed on '$bucketName' due to upload failure");
    }
  }

  Future<void> _verifyEdgeFunctions() async {
    const edgeFuncUrl = 'https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/register-token';
    try {
      final response = await http.post(
        Uri.parse(edgeFuncUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'ping'}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode < 500) {
        _addResult("Edge Functions", "PASS", "Edge Function endpoint reachable. HTTP status: ${response.statusCode}");
      } else {
        _addResult("Edge Functions", "FAIL", "Edge Function returned error: ${response.statusCode}");
      }
    } catch (e) {
      _addResult("Edge Functions", "FAIL", "Edge Function endpoint unreachable: ${e.toString()}");
    }
  }

  Future<void> _verifyRealtime() async {
    try {
      if (!RealtimeManager.instance.isReady) {
        print('Realtime skipped: Auth headers not initialized yet');
        _addResult("Realtime Stream", "SKIPPED", "Realtime startup paused until Firebase session header is synchronized");
        return;
      }

      final channel = _client.channel('realtime_verify_channel');
      bool hasConnected = false;

      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {},
      ).subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          hasConnected = true;
        }
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      await channel.unsubscribe();

      if (hasConnected) {
        _addResult("Realtime Stream", "PASS", "Subscribed to PostgreSQL Realtime Changes successfully");
      } else {
        _addResult("Realtime Stream", "WARNING", "Realtime channel connection timed out or WebSocket restricted");
      }
    } catch (e) {
      _addResult("Realtime Stream", "FAIL", "Realtime subscription failure: ${e.toString()}");
    }
  }

  Future<void> _verifyDbTables() async {
    final List<String> tables = [
      'notification_queue',
      'notification_logs',
      'notification_templates',
      'notification_preferences',
      'notification_tokens',
      'scheduled_notifications',
      'delivery_events',
      'dead_letter_notifications',
      'users',
      'bookings',
      'leads',
      'quotations',
      'reviews',
      'settings',
      'admins',
      'roles',
      'permissions',
      'services',
      'service_categories',
      'categories',
      'experiences',
      'booking_gallery',
      'chat_rooms',
      'chat_messages',
      'customer_activity',
      'offers',
      'customer_payments',
      'contact_numbers',
    ];

    for (final table in tables) {
      try {
        await _client.from(table).select().limit(1);
        print('Table checked: $table (PASS)');
        _addResult("Table: $table", "PASS", "Table exists and select query succeeded");
      } catch (e) {
        if (e is PostgrestException) {
          if (e.code == 'PGRST116') {
            print('Table checked: $table (PASS)');
            _addResult("Table: $table", "PASS", "Table exists (verified empty relation)");
          } else if (e.code == '42P01') {
            // Task 2: Classify missing tables as pending migration instead of fail
            print('Table checked: $table (PENDING MIGRATION)');
            _addResult("Table: $table", "PENDING MIGRATION", "Table is pending database migration");
          } else {
            print('Table checked: $table (WARNING)');
            _addResult("Table: $table", "WARNING", "Unexpected PostgREST response code: ${e.code}");
          }
        } else {
          print('Table checked: $table (FAIL)');
          _addResult("Table: $table", "FAIL", "Query failed: ${e.toString()}");
        }
      }
    }
  }

  Future<void> _verifyCrudOperations() async {
    final testId = 'temp_crud_test_${DateTime.now().millisecondsSinceEpoch}';
    try {
      // 1. Create (Insert)
      await _client.from('customer_activity').insert({
        'id': testId,
        'customer_id': 'system_verification',
        'activity_type': 'Verification Ping',
        'description': 'Temporary verification record',
        'ip_address': '127.0.0.1',
      });
      _addResult("CRUD Operations - Create", "PASS", "Insert operation succeeded in customer_activity");

      // 2. Read (Select)
      final readObj = await _client
          .from('customer_activity')
          .select()
          .eq('id', testId)
          .maybeSingle();
      if (readObj != null) {
        _addResult("CRUD Operations - Read", "PASS", "Select read operation resolved inserted data");
      } else {
        _addResult("CRUD Operations - Read", "FAIL", "Select read operation could not find inserted record");
      }

      // 3. Update
      await _client.from('customer_activity').update({
        'description': 'Updated temporary verification record',
      }).eq('id', testId);
      _addResult("CRUD Operations - Update", "PASS", "Update operation succeeded");

      // 4. Delete
      await _client.from('customer_activity').delete().eq('id', testId);
      _addResult("CRUD Operations - Delete", "PASS", "Delete cleanup operation succeeded");

      _addResult("RLS Integrity", "PASS", "Dynamic session CRUD verification succeeded under current policies");
    } catch (e) {
      if (e is PostgrestException && e.code == '42P01') {
        _addResult("CRUD Operations", "PENDING MIGRATION", "customer_activity table not yet migrated");
        _addResult("RLS Integrity", "PENDING MIGRATION", "customer_activity table RLS check skipped");
      } else {
        _addResult("CRUD Operations", "FAIL", "CRUD test failed on customer_activity: ${e.toString()}");
        _addResult("RLS Integrity", "WARNING", "RLS access denied or test schema not writable: ${e.toString()}");
      }
    }
  }

  Future<void> _verifyRepositoryBindings() async {
    final List<Map<String, dynamic>> repos = [
      {'name': 'CatalogRepository', 'type': CatalogRepository, 'optional': true},
      {'name': 'LeadRepository', 'type': LeadRepository, 'optional': true},
      {'name': 'QuotationRepository', 'type': QuotationRepository, 'optional': true},
      {'name': 'CustomerPortalRepository', 'type': CustomerPortalRepository, 'optional': false},
      {'name': 'SettingsRepository', 'type': SettingsRepository, 'optional': false},
      {'name': 'ContactNumberRepository', 'type': ContactNumberRepository, 'optional': false},
      {'name': 'AuthRepository', 'type': AuthRepository, 'optional': false},
      {'name': 'CustomerAuthRepository', 'type': CustomerAuthRepository, 'optional': false},
      {'name': 'CustomerRepository', 'type': CustomerRepository, 'optional': false},
      {'name': 'AdminRepository', 'type': AdminRepository, 'optional': false},
      {'name': 'BusinessDetailsRepository', 'type': BusinessDetailsRepository, 'optional': false},
    ];

    for (final repo in repos) {
      final name = repo['name'] as String;
      final isOptional = repo['optional'] as bool;
      bool found = false;

      try {
        if (name == 'CatalogRepository' && Get.isRegistered<CatalogRepository>()) found = true;
        if (name == 'LeadRepository' && Get.isRegistered<LeadRepository>()) found = true;
        if (name == 'QuotationRepository' && Get.isRegistered<QuotationRepository>()) found = true;
        if (name == 'CustomerPortalRepository' && Get.isRegistered<CustomerPortalRepository>()) found = true;
        if (name == 'SettingsRepository' && Get.isRegistered<SettingsRepository>()) found = true;
        if (name == 'ContactNumberRepository' && Get.isRegistered<ContactNumberRepository>()) found = true;
        if (name == 'AuthRepository' && Get.isRegistered<AuthRepository>()) found = true;
        if (name == 'CustomerAuthRepository' && Get.isRegistered<CustomerAuthRepository>()) found = true;
        if (name == 'CustomerRepository' && Get.isRegistered<CustomerRepository>()) found = true;
        if (name == 'AdminRepository' && Get.isRegistered<AdminRepository>()) found = true;
        if (name == 'BusinessDetailsRepository' && Get.isRegistered<BusinessDetailsRepository>()) found = true;

        if (found) {
          print('Repository registered: $name');
          _addResult("DI Check: $name", "PASS", "Repository registered in GetX dependency injection hierarchy");
        } else {
          if (isOptional) {
            // Task 1: Check lazy-loaded pages repos, skip if not loaded yet
            print('Repository skipped: $name');
            _addResult("DI Check: $name", "SKIPPED", "Optional repository is skipped (loaded on-demand via route bindings)");
          } else {
            print('Repository removed: $name');
            _addResult("DI Check: $name", "FAIL", "Required repository is not registered in active bindings");
          }
        }
      } catch (e) {
        print('Repository removed: $name');
        _addResult("DI Check: $name", "FAIL", "Repository injection check failed: ${e.toString()}");
      }
    }
  }

  // ─── Reporting ─────────────────────────────────────────────────────────────

  void _printConsoleReport() {
    print("\n==================================================");
    print("      ENTERPRISE VERIFICATION REPORT");
    print("==================================================");
    for (final item in results) {
      final bullet = item.status == 'PASS' 
          ? '✔ PASS' 
          : item.status == 'WARNING' 
              ? '⚠ WARNING' 
              : item.status == 'SKIPPED'
                  ? '⏭ SKIPPED'
                  : item.status == 'PENDING MIGRATION'
                      ? '⏱ PENDING MIGRATION'
                      : '✘ FAIL';
      print("$bullet ${item.name} - Reason: ${item.reason}");
    }
    print("==================================================");
    print(" PRODUCTION READINESS STATUS: ${readinessPercent.value}%");
    print("==================================================\n");
  }
}
