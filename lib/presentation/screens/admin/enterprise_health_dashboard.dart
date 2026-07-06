import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/enterprise_verification_service.dart';

class EnterpriseHealthDashboard extends StatefulWidget {
  const EnterpriseHealthDashboard({super.key});

  @override
  State<EnterpriseHealthDashboard> createState() => _EnterpriseHealthDashboardState();
}

class _EnterpriseHealthDashboardState extends State<EnterpriseHealthDashboard> {
  final EnterpriseVerificationService _service = EnterpriseVerificationService.to;
  String _filter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13),
      appBar: AppBar(
        title: Text(
          'ENTERPRISE HEALTH DASHBOARD',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF16151D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF4081)),
            onPressed: () => _service.runFullVerification(),
          ),
        ],
      ),
      body: Obx(() {
        if (_service.isVerifying.value && _service.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF4081)),
                const SizedBox(height: 24),
                Text(
                  'RUNNING BACKEND HEALTH AUDIT...',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Apply filters & search
        final filteredItems = _service.results.where((item) {
          final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.reason.toLowerCase().contains(_searchQuery.toLowerCase());
          
          if (!matchesSearch) return false;
          if (_filter == 'ALL') return true;
          if (_filter == 'PASS') return item.status == 'PASS';
          if (_filter == 'WARNING') return item.status == 'WARNING';
          if (_filter == 'FAIL') return item.status == 'FAIL';
          return true;
        }).toList();

        final passCount = _service.results.where((item) => item.status == 'PASS').length;
        final warningCount = _service.results.where((item) => item.status == 'WARNING').length;
        final failCount = _service.results.where((item) => item.status == 'FAIL').length;

        return Column(
          children: [
            // Status Summary Header
            _buildSummaryHeader(passCount, warningCount, failCount),

            // Search and Category Tabs
            _buildSearchAndFilters(),

            // Audit Logs
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'NO VERIFICATION LOGS FOUND',
                        style: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildVerificationCard(item);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryHeader(int passes, int warnings, int fails) {
    final percent = _service.readinessPercent.value;
    final Color progressColor = percent >= 90
        ? const Color(0xFF00E676)
        : percent >= 70
            ? const Color(0xFFFFD600)
            : const Color(0xFFFF1744);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Health Statistics Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTION READINESS',
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  percent >= 90 ? 'SYSTEM READY' : percent >= 75 ? 'DEGRADED RUNTIME' : 'CRITICAL ERRORS DETECTED',
                  style: GoogleFonts.outfit(
                    color: progressColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill('🟢 PASS', passes, const Color(0xFF00E676)),
                    _buildStatPill('🟡 WARN', warnings, const Color(0xFFFFD600)),
                    _buildStatPill('🔴 FAIL', fails, const Color(0xFFFF1744)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $val',
        style: GoogleFonts.outfit(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search audit tests...',
              hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.white30, size: 20),
              filled: true,
              fillColor: const Color(0xFF16151D),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['ALL', 'PASS', 'WARNING', 'FAIL'].map((type) {
              final isSelected = _filter == type;
              return GestureDetector(
                onTap: () => setState(() => _filter = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF4081) : const Color(0xFF16151D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildVerificationCard(VerificationItem item) {
    Color statusColor;
    IconData statusIcon;

    if (item.status == 'PASS') {
      statusColor = const Color(0xFF00E676);
      statusIcon = Icons.check_circle_outline;
    } else if (item.status == 'WARNING') {
      statusColor = const Color(0xFFFFD600);
      statusIcon = Icons.warning_amber_rounded;
    } else if (item.status == 'SKIPPED') {
      statusColor = const Color(0xFF9E9E9E);
      statusIcon = Icons.next_plan_outlined;
    } else if (item.status == 'PENDING MIGRATION' || item.status == 'NOT IMPLEMENTED') {
      statusColor = const Color(0xFF29B6F6);
      statusIcon = Icons.pending_actions_rounded;
    } else {
      statusColor = const Color(0xFFFF1744);
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.reason,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.status,
              style: GoogleFonts.outfit(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
