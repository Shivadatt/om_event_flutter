import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SchedulerHealthController
// Reads cron_health_summary and recent cron_health_logs from Firestore.
// Updated in real-time via snapshot streams.
// ─────────────────────────────────────────────────────────────────────────────

class CronJobSummary {
  final String jobName;
  final String lastStatus;
  final String lastRun;
  final int lastDurationMs;
  final int lastProcessedItems;
  final int totalFailures;
  final String? lastError;
  final String schedule;

  const CronJobSummary({
    required this.jobName,
    required this.lastStatus,
    required this.lastRun,
    required this.lastDurationMs,
    required this.lastProcessedItems,
    required this.totalFailures,
    this.lastError,
    required this.schedule,
  });

  factory CronJobSummary.fromMap(Map<String, dynamic> m) {
    return CronJobSummary(
      jobName: m['jobName'] as String? ?? '',
      lastStatus: m['lastStatus'] as String? ?? 'unknown',
      lastRun: m['lastRun'] as String? ?? '',
      lastDurationMs: (m['lastDurationMs'] as num?)?.toInt() ?? 0,
      lastProcessedItems: (m['lastProcessedItems'] as num?)?.toInt() ?? 0,
      totalFailures: (m['totalFailures'] as num?)?.toInt() ?? 0,
      lastError: m['lastError'] as String?,
      schedule: m['schedule'] as String? ?? _scheduleFor(m['jobName'] as String? ?? ''),
    );
  }

  static String _scheduleFor(String jobName) {
    const Map<String, String> schedules = {
      'check-scheduled-reminders': 'Every 30 min',
      'check-quotation-expiry': 'Every hour (0 min)',
      'send-expiry-reminders': 'Every hour (5 min)',
      'send-followups': 'Every hour (10 min)',
      'send-booking-reminders': 'Daily 06:00',
      'process-notification-queue': 'Every 30 min',
      'cleanup-old-automation-logs': 'Daily 01:00',
      'calculate-analytics': 'Daily 02:00',
      'daily-digest': 'Daily 09:00',
    };
    return schedules[jobName] ?? 'Custom';
  }
}

class CronJobLog {
  final String id;
  final String jobName;
  final String status;
  final String startedAt;
  final String? completedAt;
  final int durationMs;
  final int processedItems;
  final String? errorMessage;

  const CronJobLog({
    required this.id,
    required this.jobName,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.durationMs,
    required this.processedItems,
    this.errorMessage,
  });

  factory CronJobLog.fromMap(String id, Map<String, dynamic> m) {
    return CronJobLog(
      id: id,
      jobName: m['jobName'] as String? ?? '',
      status: m['status'] as String? ?? 'unknown',
      startedAt: m['startedAt'] as String? ?? '',
      completedAt: m['completedAt'] as String?,
      durationMs: (m['durationMs'] as num?)?.toInt() ?? 0,
      processedItems: (m['processedItems'] as num?)?.toInt() ?? 0,
      errorMessage: m['errorMessage'] as String?,
    );
  }
}

class SchedulerHealthController extends GetxController {
  static SchedulerHealthController get to => Get.find();

  final _firestore = FirebaseFirestore.instance;

  final RxList<CronJobSummary> rxSummaries = <CronJobSummary>[].obs;
  final RxList<CronJobLog> rxRecentLogs = <CronJobLog>[].obs;
  final RxBool rxIsLoading = true.obs;
  final RxString rxError = ''.obs;
  final RxString rxSelectedJobFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  void _bindStreams() {
    rxIsLoading.value = true;

    _firestore
        .collection('cron_health_summary')
        .snapshots()
        .listen((snap) {
      rxSummaries.value = snap.docs
          .map((d) => CronJobSummary.fromMap(d.data()))
          .toList()
        ..sort((a, b) => b.lastRun.compareTo(a.lastRun));
      rxIsLoading.value = false;
    }, onError: (e) {
      rxError.value = e.toString();
      rxIsLoading.value = false;
      if (kDebugMode) debugPrint('SchedulerHealthController: $e');
    });

    _firestore
        .collection('cron_health_logs')
        .orderBy('startedAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      rxRecentLogs.value = snap.docs
          .map((d) => CronJobLog.fromMap(d.id, d.data()))
          .toList();
    }, onError: (e) {
      if (kDebugMode) debugPrint('SchedulerHealthController logs: $e');
    });
  }

  List<CronJobLog> get filteredLogs {
    final filter = rxSelectedJobFilter.value;
    if (filter == 'all') return rxRecentLogs;
    return rxRecentLogs.where((l) => l.jobName == filter).toList();
  }

  int get totalSuccessCount =>
      rxSummaries.where((s) => s.lastStatus == 'success').length;

  int get totalFailureCount =>
      rxSummaries.where((s) => s.lastStatus == 'failed').length;

  int get totalSkippedCount =>
      rxSummaries.where((s) => s.lastStatus == 'skipped').length;

  @override
  void refresh() => _bindStreams();
}
