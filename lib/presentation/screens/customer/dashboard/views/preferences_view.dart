import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Renders customer notification preferences matching Option 4: Premium Detailed Style.
class PreferencesView extends StatefulWidget {
  final CustomerDashboardController controller;

  const PreferencesView({
    super.key,
    required this.controller,
  });

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  // Delivery Channels
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool whatsappEnabled = true;

  // Categories
  bool quotationEnabled = true;
  bool reviewEnabled = true;
  bool supportEnabled = true;
  bool offerEnabled = true;
  bool newsletterEnabled = false;

  // Preserved background fields
  bool bookingEnabled = true;
  bool paymentEnabled = true;
  bool reminderEnabled = true;
  bool marketingEnabled = false;

  // Quiet Hours (DND)
  bool dndEnabled = false;
  String quietHoursStart = '23:00';
  String quietHoursEnd = '06:00';

  // Daily Digest
  bool dailyDigestEnabled = true;

  bool isLoading = true;
  bool isSaving = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final profile = widget.controller.rxProfile.value;
      if (profile != null) {
        userId = profile.id;
        await widget.controller.loadNotificationPreferences(userId!);
        final data = widget.controller.rxPreferences;
        if (data.isNotEmpty) {
          setState(() {
            pushEnabled = data['pushEnabled'] ?? true;
            emailEnabled = data['emailEnabled'] ?? true;
            whatsappEnabled = data['whatsappEnabled'] ?? true;
            bookingEnabled = data['bookingEnabled'] ?? true;
            paymentEnabled = data['paymentEnabled'] ?? true;
            quotationEnabled = data['quotationEnabled'] ?? true;
            reviewEnabled = data['reviewEnabled'] ?? true;
            offerEnabled = data['offerEnabled'] ?? (data['marketingEnabled'] ?? true);
            supportEnabled = data['supportEnabled'] ?? true;
            reminderEnabled = data['reminderEnabled'] ?? true;
            marketingEnabled = data['marketingEnabled'] ?? false;
            newsletterEnabled = data['newsletterEnabled'] ?? false;
            dndEnabled = data['dndEnabled'] ?? false;
            quietHoursStart = data['quietHoursStart'] ?? '23:00';
            quietHoursEnd = data['quietHoursEnd'] ?? '06:00';
            dailyDigestEnabled = data['dailyDigestEnabled'] ?? true;
          });
        }
      }
    } catch (_) {
      // Fail silently
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    if (userId == null) return;
    try {
      setState(() => isSaving = true);
      final data = {
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
        'whatsappEnabled': whatsappEnabled,
        'bookingEnabled': bookingEnabled,
        'paymentEnabled': paymentEnabled,
        'quotationEnabled': quotationEnabled,
        'reviewEnabled': reviewEnabled,
        'offerEnabled': offerEnabled,
        'supportEnabled': supportEnabled,
        'reminderEnabled': reminderEnabled,
        'marketingEnabled': offerEnabled,
        'newsletterEnabled': newsletterEnabled,
        'dndEnabled': dndEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'dailyDigestEnabled': dailyDigestEnabled,
      };
      await widget.controller.saveNotificationPreferences(userId!, data);
    } catch (_) {
      // Fail silently
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 880;
        final bool isTablet = constraints.maxWidth >= 600 && !isDesktop;
        final double horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title + Preview Sample Alerts button
              _buildHeader(isDesktop: isDesktop),
              const SizedBox(height: 22),

              // Main 2-Column Grid (Delivery Channels | Quiet Hours + Daily Digest)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDeliveryChannelsCard()),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        children: [
                          _buildQuietHoursCard(),
                          const SizedBox(height: 14),
                          _buildDailyDigestCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildDeliveryChannelsCard(),
                const SizedBox(height: 14),
                _buildQuietHoursCard(),
                const SizedBox(height: 14),
                _buildDailyDigestCard(),
              ],

              const SizedBox(height: 24),

              // Notification Categories Section
              _buildNotificationCategoriesSection(constraints: constraints),

              const SizedBox(height: 28),

              // Bottom Save Settings Button
              Center(
                child: SizedBox(
                  width: isDesktop ? 440 : double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF091210),
                            ),
                          )
                        : const Icon(Icons.lock_outline_rounded, size: 16),
                    label: Text(
                      isSaving ? "SAVING PREFERENCES..." : "SAVE NOTIFICATION SETTINGS",
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: const Color(0xFF091210),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5C378),
                      foregroundColor: const Color(0xFF091210),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isSaving ? null : _savePreferences,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ── 1. Page Header ─────────────────────────────────────────────────────────
  Widget _buildHeader({required bool isDesktop}) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildHeaderTitles()),
          _buildPreviewAlertsButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderTitles(),
        const SizedBox(height: 14),
        _buildPreviewAlertsButton(),
      ],
    );
  }

  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "COMMUNICATION KEYS",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Notification Preferences",
          style: GoogleFonts.italiana(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Stay in control of what you receive and when. Tailored updates for a smoother experience.",
          style: AppTheme.sansBody(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewAlertsButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFFD4AF37)),
      label: const Text(
        "Preview Sample Alerts",
        style: TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: _showPreviewSampleAlertsDialog,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0x55D4AF37), width: 1.1),
        backgroundColor: const Color(0x12D4AF37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── 2. Delivery Channels Card ─────────────────────────────────────────────
  Widget _buildDeliveryChannelsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DELIVERY CHANNELS",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildChannelRow(
            icon: Icons.notifications_none_rounded,
            title: "Push Notifications",
            subtitle: "Receive direct device and browser alerts",
            value: pushEnabled,
            onChanged: (val) => setState(() => pushEnabled = val),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0x14D4AF37)),
          const SizedBox(height: 12),
          _buildChannelRow(
            icon: Icons.mail_outline_rounded,
            title: "Email Messages",
            subtitle: "Receive custom HTML proposals and contract details",
            value: emailEnabled,
            onChanged: (val) => setState(() => emailEnabled = val),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0x14D4AF37)),
          const SizedBox(height: 12),
          _buildChannelRow(
            icon: Icons.phone_iphone_rounded,
            title: "WhatsApp Alerts",
            subtitle: "Receive template updates to your registered phone",
            value: whatsappEnabled,
            onChanged: (val) => setState(() => whatsappEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        // Left circular icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF14201A),
            border: Border.all(color: const Color(0x33D4AF37)),
          ),
          child: Center(
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          ),
        ),
        const SizedBox(width: 14),

        // Text details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Toggle + Chevron
        _buildLuxurySwitch(value: value, onChanged: onChanged),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 16, color: Color(0x66D4AF37)),
      ],
    );
  }

  // ── 3. Quiet Hours Card ───────────────────────────────────────────────────
  Widget _buildQuietHoursCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "QUIET HOURS (DO NOT DISTURB)",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Enable DND row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14201A),
                  border: Border.all(color: const Color(0x33D4AF37)),
                ),
                child: const Center(
                  child: Icon(Icons.bedtime_outlined, color: Color(0xFFD4AF37), size: 18),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enable Quiet Hours (DND)",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Pause low-priority alerts during quiet hours",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLuxurySwitch(
                value: dndEnabled,
                onChanged: (val) => setState(() => dndEnabled = val),
              ),
            ],
          ),

          // Time pickers row (From / To)
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF070D0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x1AD4AF37)),
            ),
            child: Row(
              children: [
                const Text(
                  "From",
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimeDropdown(
                    value: quietHoursStart,
                    items: const [
                      '20:00',
                      '21:00',
                      '22:00',
                      '23:00',
                      '00:00',
                    ],
                    labelMap: const {
                      '20:00': '08:00 PM',
                      '21:00': '09:00 PM',
                      '22:00': '10:00 PM',
                      '23:00': '11:00 PM',
                      '00:00': '12:00 AM',
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => quietHoursStart = val);
                    },
                  ),
                ),
                const SizedBox(width: 18),
                const Text(
                  "To",
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimeDropdown(
                    value: quietHoursEnd,
                    items: const [
                      '05:00',
                      '06:00',
                      '07:00',
                      '08:00',
                      '09:00',
                    ],
                    labelMap: const {
                      '05:00': '05:00 AM',
                      '06:00': '06:00 AM',
                      '07:00': '07:00 AM',
                      '08:00': '08:00 AM',
                      '09:00': '09:00 AM',
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => quietHoursEnd = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDropdown({
    required String value,
    required List<String> items,
    required Map<String, String> labelMap,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value) ? value : items.first;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: validValue,
        isDense: true,
        isExpanded: true,
        dropdownColor: const Color(0xFF14201A),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD4AF37), size: 18),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        items: items.map((val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(labelMap[val] ?? val),
          );
        }).toList(),
        onChanged: dndEnabled ? onChanged : null,
      ),
    );
  }

  // ── 4. Daily Digest Card ──────────────────────────────────────────────────
  Widget _buildDailyDigestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DAILY DIGEST",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14201A),
                  border: Border.all(color: const Color(0x33D4AF37)),
                ),
                child: const Center(
                  child: Icon(Icons.article_outlined, color: Color(0xFFD4AF37), size: 18),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receive Daily Digest Summaries",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Batch low-priority inquiries into a single daily briefing",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLuxurySwitch(
                value: dailyDigestEnabled,
                onChanged: (val) => setState(() => dailyDigestEnabled = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Notification Categories Section ─────────────────────────────────────
  Widget _buildNotificationCategoriesSection({required BoxConstraints constraints}) {
    final categories = [
      _CategoryItem(
        title: "Quotation Proposal Updates",
        icon: Icons.description_outlined,
        value: quotationEnabled,
        onToggle: () => setState(() => quotationEnabled = !quotationEnabled),
      ),
      _CategoryItem(
        title: "Design Review Requests",
        icon: Icons.draw_outlined,
        value: reviewEnabled,
        onToggle: () => setState(() => reviewEnabled = !reviewEnabled),
      ),
      _CategoryItem(
        title: "Support Ticket Replies",
        icon: Icons.headset_mic_outlined,
        value: supportEnabled,
        onToggle: () => setState(() => supportEnabled = !supportEnabled),
      ),
      _CategoryItem(
        title: "Exclusive Campaigns & Promos",
        icon: Icons.local_offer_outlined,
        value: offerEnabled,
        onToggle: () => setState(() => offerEnabled = !offerEnabled),
      ),
      _CategoryItem(
        title: "Studio Newsletters",
        icon: Icons.mark_email_read_outlined,
        value: newsletterEnabled,
        onToggle: () => setState(() => newsletterEnabled = !newsletterEnabled),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NOTIFICATION CATEGORIES",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        if (constraints.maxWidth >= 940)
          Row(
            children: categories.map((cat) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCategoryCard(cat),
                ),
              );
            }).toList(),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((cat) {
              final cardWidth = constraints.maxWidth >= 600
                  ? (constraints.maxWidth - 48 - 24) / 3
                  : (constraints.maxWidth - 32 - 12) / 2;
              return SizedBox(
                width: cardWidth,
                child: _buildCategoryCard(cat),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCategoryCard(_CategoryItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 125,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.value
                  ? const Color(0xFFD4AF37).withValues(alpha: 0.6)
                  : const Color(0x22D4AF37),
              width: item.value ? 1.2 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14201A),
                  border: Border.all(
                    color: item.value ? const Color(0xFFD4AF37) : const Color(0x33D4AF37),
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    color: item.value ? const Color(0xFFD4AF37) : Colors.white60,
                    size: 17,
                  ),
                ),
              ),

              // Title
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),

              // Bottom Checkbox Indicator
              Row(
                children: [
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: item.value ? const Color(0xFFD4AF37) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: item.value ? const Color(0xFFD4AF37) : const Color(0x66D4AF37),
                        width: 1.2,
                      ),
                    ),
                    child: item.value
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Color(0xFF091210),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 6. Luxury Switch Widget ───────────────────────────────────────────────
  Widget _buildLuxurySwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      activeThumbColor: const Color(0xFF091210),
      activeTrackColor: const Color(0xFFE5C378),
      inactiveThumbColor: Colors.white60,
      inactiveTrackColor: const Color(0xFF232D27),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? const Color(0xFFD4AF37)
            : const Color(0x33D4AF37),
      ),
      onChanged: onChanged,
    );
  }

  // ── 7. Sample Alerts Preview Dialog ───────────────────────────────────────
  void _showPreviewSampleAlertsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x1AD4AF37),
                      border: Border.all(color: const Color(0x40D4AF37)),
                    ),
                    child: const Center(
                      child: Icon(Icons.visibility_outlined, color: Color(0xFFD4AF37), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preview Sample Alerts",
                          style: GoogleFonts.italiana(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "How OM Events notifications appear on your devices",
                          style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0x1AD4AF37)),
              const SizedBox(height: 14),

              // Preview samples list
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Push Preview
                      _buildAlertSampleTile(
                        channelTitle: "PUSH NOTIFICATION",
                        channelColor: const Color(0xFFD4AF37),
                        title: "Proposal Ready: Royal Heritage Reception",
                        message: "Your bespoke quotation (v2) has been prepared by our senior designer.",
                        timestamp: "2m ago",
                        icon: Icons.notifications_active_outlined,
                      ),
                      const SizedBox(height: 12),

                      // WhatsApp Preview
                      _buildAlertSampleTile(
                        channelTitle: "WHATSAPP TEMPLATE",
                        channelColor: const Color(0xFF25D366),
                        title: "OM Events Logistics Coordinator",
                        message: "Namaste! Your floral installation schedule for Dec 18 has been confirmed.",
                        timestamp: "10m ago",
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                      const SizedBox(height: 12),

                      // Email Preview
                      _buildAlertSampleTile(
                        channelTitle: "EMAIL DIGEST",
                        channelColor: const Color(0xFF64B5F6),
                        title: "OM Events Daily Briefing",
                        message: "1 design revision waiting for your review. Venue floorplan updated.",
                        timestamp: "Today, 9:00 AM",
                        icon: Icons.mail_outline_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF091210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertSampleTile({
    required String channelTitle,
    required Color channelColor,
    required String title,
    required String message,
    required String timestamp,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF070D0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: channelColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: channelColor),
              const SizedBox(width: 6),
              Text(
                channelTitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: channelColor,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                timestamp,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final bool value;
  final VoidCallback onToggle;

  const _CategoryItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.onToggle,
  });
}
