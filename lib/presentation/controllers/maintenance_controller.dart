import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/supabase_edge_functions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MaintenanceController
//
// All heavy batch operations are now delegated to the Supabase Edge Function
// `run-maintenance-job`. This controller only:
//   1. Fires the job via SupabaseEdgeFunctions
//   2. Polls Firestore maintenance_jobs/{jobId} for live progress
//   3. Cancels by writing cancel=true to that Firestore doc
//   4. Reads audit history from maintenance_logs
//
// No client-side batch Firestore writes. No production isolates.
// ─────────────────────────────────────────────────────────────────────────────

class MaintenanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Observable State ──────────────────────────────────────────────────────
  final rxIsProcessing = false.obs;
  final rxProgress = 0.0.obs;
  final rxStatusMessage = 'Ready'.obs;
  final rxScanned = 0.obs;
  final rxValid = 0.obs;
  final rxNeedsUpdate = 0.obs;
  final rxFailed = 0.obs;
  final rxSkipped = 0.obs;
  final rxWrites = 0.obs;
  final rxReads = 0.obs;
  final rxTimeStr = '0s'.obs;
  final rxDryRunReport = ''.obs;
  final rxCurrentJobId = ''.obs;

  StreamSubscription<DocumentSnapshot>? _progressSub;

  @override
  void onClose() {
    _progressSub?.cancel();
    super.onClose();
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────

  /// Writes cancel=true to the running job's Firestore doc.
  /// The Edge Function polls this flag and stops gracefully after the current batch.
  Future<void> cancelOperation() async {
    if (rxCurrentJobId.value.isEmpty) {
      rxStatusMessage.value = 'No active job to cancel';
      return;
    }
    rxStatusMessage.value = 'Sending cancel signal...';
    try {
      await _firestore
          .collection('maintenance_jobs')
          .doc(rxCurrentJobId.value)
          .update({'cancel': true});
      rxStatusMessage.value = 'Cancel signal sent — stopping after current batch';
    } catch (e) {
      rxStatusMessage.value = 'Cancel failed: $e';
    }
  }

  // ─── Dry Run ──────────────────────────────────────────────────────────────

  /// Runs a dry-run estimation via the Edge Function.
  /// No Firestore writes are made; the function just counts and estimates.
  Future<void> runDryRun(String operationType) async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    _resetStats();
    rxStatusMessage.value = 'Running server-side dry run: $operationType…';

    try {
      final jobId = 'dryrun_${DateTime.now().millisecondsSinceEpoch}';
      rxCurrentJobId.value = jobId;

      final result = await SupabaseEdgeFunctions.to.invokeMaintenanceJob(
        operation: operationType,
        dryRun: true,
        jobId: jobId,
      );

      if (result.success) {
        final data = result.data;
        rxScanned.value = data['processedItems'] as int? ?? 0;
        rxNeedsUpdate.value = rxScanned.value;
        rxSkipped.value = data['skippedItems'] as int? ?? 0;
        rxDryRunReport.value = 'DRY RUN SUMMARY:\n'
            'Scanned: ${rxScanned.value}\n'
            'Would Update: ${rxNeedsUpdate.value}\n'
            'Skipped: ${rxSkipped.value}\n'
            'Dry Run: true';
        rxStatusMessage.value = 'Dry Run Completed';
      } else {
        rxStatusMessage.value = 'Dry Run Failed: ${result.error}';
      }
    } catch (e) {
      rxStatusMessage.value = 'Dry Run Error: $e';
    } finally {
      rxIsProcessing.value = false;
    }
  }

  // ─── Live Migration ────────────────────────────────────────────────────────

  /// Executes the live migration on the server. Polls Firestore for progress.
  Future<void> executeMigration(String operationType) async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    _resetStats();
    rxStatusMessage.value = 'Starting server-side migration: $operationType…';

    final jobId = 'maint_${DateTime.now().millisecondsSinceEpoch}';
    rxCurrentJobId.value = jobId;

    try {
      // 1. Start the job (non-blocking — Edge Function runs async)
      final result = await SupabaseEdgeFunctions.to.invokeMaintenanceJob(
        operation: operationType,
        dryRun: false,
        jobId: jobId,
      );

      if (!result.success) {
        rxStatusMessage.value = 'Failed to start: ${result.error}';
        rxIsProcessing.value = false;
        return;
      }

      // 2. Poll Firestore maintenance_jobs/{jobId} for live progress
      _progressSub?.cancel();
      _progressSub = _firestore
          .collection('maintenance_jobs')
          .doc(jobId)
          .snapshots()
          .listen((snap) {
        if (!snap.exists) return;
        final data = snap.data()!;

        rxProgress.value = (data['progress'] as num?)?.toDouble() ?? 0.0;
        rxScanned.value = data['scanned'] as int? ?? 0;
        rxNeedsUpdate.value = data['updated'] as int? ?? 0;
        rxSkipped.value = data['skipped'] as int? ?? 0;

        final status = data['status'] as String? ?? 'running';

        switch (status) {
          case 'running':
            rxStatusMessage.value =
                'Processing ${rxScanned.value} documents… '
                '(${(rxProgress.value * 100).toStringAsFixed(0)}%)';
            break;
          case 'success':
            rxStatusMessage.value = 'Migration Complete!';
            rxProgress.value = 1.0;
            rxIsProcessing.value = false;
            _progressSub?.cancel();
            break;
          case 'cancelled':
            rxStatusMessage.value = 'Cancelled';
            rxIsProcessing.value = false;
            _progressSub?.cancel();
            break;
          case 'failed':
            rxStatusMessage.value = 'Failed: ${data['error'] ?? 'Unknown error'}';
            rxIsProcessing.value = false;
            _progressSub?.cancel();
            break;
        }
      });

      // Timeout safety: if no completion in 60s, stop polling
      await Future.delayed(const Duration(seconds: 60));
      if (rxIsProcessing.value) {
        _progressSub?.cancel();
        rxIsProcessing.value = false;
        if (rxStatusMessage.value.contains('Processing')) {
          rxStatusMessage.value = 'Timed out — check Scheduler Health for status';
        }
      }
    } catch (e) {
      rxStatusMessage.value = 'Migration Error: $e';
      rxIsProcessing.value = false;
    }
  }

  // ─── PDF Regeneration ─────────────────────────────────────────────────────

  /// Regenerate the PDF contract for a single quotation.
  Future<void> regeneratePdf(String quotationId) async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    rxStatusMessage.value = 'Regenerating PDF for $quotationId…';

    try {
      final result = await SupabaseEdgeFunctions.to.regeneratePdf(quotationId);
      rxStatusMessage.value = result.success
          ? 'PDF regenerated successfully'
          : 'PDF failed: ${result.error}';
    } catch (e) {
      rxStatusMessage.value = 'PDF Error: $e';
    } finally {
      rxIsProcessing.value = false;
    }
  }

  /// Batch regenerate PDFs for all quotations missing pdfUrl.
  Future<void> batchRegeneratePdfs() async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    rxStatusMessage.value = 'Batch regenerating PDFs…';

    try {
      final result = await SupabaseEdgeFunctions.to.batchRegeneratePdfs();
      rxStatusMessage.value = result.success
          ? 'Batch PDF complete: ${result.data['processedItems'] ?? 0} generated'
          : 'Batch PDF failed: ${result.error}';
    } catch (e) {
      rxStatusMessage.value = 'Batch PDF Error: $e';
    } finally {
      rxIsProcessing.value = false;
    }
  }

  // ─── Version Cleanup ──────────────────────────────────────────────────────

  Future<void> runVersionCleanup() async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    rxStatusMessage.value = 'Running version cleanup…';

    try {
      final result = await SupabaseEdgeFunctions.to.runVersionCleanup();
      rxStatusMessage.value = result.success
          ? 'Cleanup complete: ${result.data['processedItems'] ?? 0} records removed'
          : 'Cleanup failed: ${result.error}';
    } catch (e) {
      rxStatusMessage.value = 'Cleanup Error: $e';
    } finally {
      rxIsProcessing.value = false;
    }
  }

  // ─── Analytics Refresh ────────────────────────────────────────────────────

  Future<void> refreshAnalytics() async {
    if (rxIsProcessing.value) return;
    rxIsProcessing.value = true;
    rxStatusMessage.value = 'Refreshing analytics…';

    try {
      final result = await SupabaseEdgeFunctions.to.calculateAnalytics();
      rxStatusMessage.value = result.success
          ? 'Analytics refreshed'
          : 'Analytics failed: ${result.error}';
    } catch (e) {
      rxStatusMessage.value = 'Analytics Error: $e';
    } finally {
      rxIsProcessing.value = false;
    }
  }

  // ─── Audit Log Reader ─────────────────────────────────────────────────────

  Stream<QuerySnapshot> get maintenanceLogsStream => _firestore
      .collection('maintenance_logs')
      .orderBy('startedAt', descending: true)
      .limit(20)
      .snapshots();

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _resetStats() {
    rxScanned.value = 0;
    rxValid.value = 0;
    rxNeedsUpdate.value = 0;
    rxFailed.value = 0;
    rxSkipped.value = 0;
    rxWrites.value = 0;
    rxReads.value = 0;
    rxTimeStr.value = '0s';
    rxDryRunReport.value = '';
    rxProgress.value = 0.0;
    rxCurrentJobId.value = '';
  }
}
