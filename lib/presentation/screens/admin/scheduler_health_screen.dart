import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/scheduler_health_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Scheduler Health Dashboard
// Shows real-time health of all pg_cron scheduled Supabase Edge Functions.
// Path: Admin → Settings → Maintenance → Scheduler Health
// ─────────────────────────────────────────────────────────────────────────────

class SchedulerHealthScreen extends StatelessWidget {
  const SchedulerHealthScreen({super.key});

  static const Color _bg = Color(0xFF0D1117);
  static const Color _surface = Color(0xFF161B22);
  static const Color _card = Color(0xFF1E2735);
  static const Color _accent = Color(0xFFD4AF37);
  static const Color _success = Color(0xFF22C55E);
  static const Color _failed = Color(0xFFEF4444);
  static const Color _skipped = Color(0xFF94A3B8);
  static const Color _running = Color(0xFF3B82F6);
  static const Color _text = Color(0xFFF0F6FC);
  static const Color _subtext = Color(0xFF8B949E);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SchedulerHealthController());

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: _text),
        title: const Text(
          'Scheduler Health',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _text,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: _accent),
            onPressed: () => controller.refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.rxIsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _accent),
          );
        }

        if (controller.rxError.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${controller.rxError.value}',
              style: const TextStyle(color: _failed, fontFamily: 'Outfit'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBar(controller),
              const SizedBox(height: 24),
              _buildSectionHeader('Cron Jobs'),
              const SizedBox(height: 12),
              _buildCronMatrix(controller),
              const SizedBox(height: 28),
              _buildSectionHeader('Recent Executions'),
              const SizedBox(height: 12),
              _buildJobFilterChips(controller),
              const SizedBox(height: 12),
              _buildRecentLogs(controller),
            ],
          ),
        );
      }),
    );
  }

  // ─── Status Bar ───────────────────────────────────────────────────────────

  Widget _buildStatusBar(SchedulerHealthController controller) {
    return Row(
      children: [
        Expanded(child: _buildStatChip('Healthy', controller.totalSuccessCount.toString(), _success)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Failed', controller.totalFailureCount.toString(), _failed)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Skipped', controller.totalSkippedCount.toString(), _skipped)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Total Jobs', controller.rxSummaries.length.toString(), _accent)),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              color: _subtext,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Cron Matrix ──────────────────────────────────────────────────────────

  Widget _buildCronMatrix(SchedulerHealthController controller) {
    final summaries = controller.rxSummaries;
    if (summaries.isEmpty) {
      return _buildEmptyState('No cron job health data found.\nJobs will appear after first execution.');
    }

    return Column(
      children: summaries.map((job) => _buildJobCard(job)).toList(),
    );
  }

  Widget _buildJobCard(CronJobSummary job) {
    final color = _statusColor(job.lastStatus);
    final lastRunText = _formatTime(job.lastRun);
    final durationText = job.lastDurationMs > 0
        ? '${job.lastDurationMs}ms'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        job.lastStatus.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  lastRunText,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: _subtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.jobName,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.schedule,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: _subtext,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMiniStat('Duration', durationText, Icons.timer_outlined),
                const SizedBox(width: 24),
                _buildMiniStat(
                  'Processed',
                  job.lastProcessedItems.toString(),
                  Icons.check_circle_outline,
                ),
                const SizedBox(width: 24),
                _buildMiniStat(
                  'Total Failures',
                  job.totalFailures.toString(),
                  Icons.error_outline,
                  valueColor: job.totalFailures > 0 ? _failed : _subtext,
                ),
              ],
            ),
            if (job.lastError != null && job.lastError!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _failed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _failed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: _failed, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.lastError!,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: _failed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon, {
    Color valueColor = _text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: _subtext),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: _subtext),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────

  Widget _buildJobFilterChips(SchedulerHealthController controller) {
    final jobs = ['all', ...controller.rxSummaries.map((s) => s.jobName)];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: jobs.map((j) {
          final isSelected = controller.rxSelectedJobFilter.value == j;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.rxSelectedJobFilter.value = j,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _accent.withValues(alpha: 0.15) : _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _accent : _subtext.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  j == 'all' ? 'All Jobs' : j,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: isSelected ? _accent : _subtext,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Recent Logs ──────────────────────────────────────────────────────────

  Widget _buildRecentLogs(SchedulerHealthController controller) {
    final logs = controller.filteredLogs;
    if (logs.isEmpty) {
      return _buildEmptyState('No recent executions found.');
    }

    return Column(
      children: logs.take(30).map((log) => _buildLogRow(log)).toList(),
    );
  }

  Widget _buildLogRow(CronJobLog log) {
    final color = _statusColor(log.status);
    final time = _formatTime(log.startedAt);
    final duration = log.durationMs > 0 ? '${log.durationMs}ms' : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.jobName,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 2),
                if (log.errorMessage != null && log.errorMessage!.isNotEmpty)
                  Text(
                    log.errorMessage!,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: _failed),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    '${log.processedItems} items processed',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: _subtext),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: _subtext),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: _subtext),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _text,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: _subtext),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return _success;
      case 'failed':
        return _failed;
      case 'running':
        return _running;
      case 'skipped':
        return _skipped;
      default:
        return _subtext;
    }
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final mon = months[dt.month - 1];
      final day = dt.day.toString();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$mon $day, $h:$m';
    } catch (_) {
      return isoString;
    }
  }
}
