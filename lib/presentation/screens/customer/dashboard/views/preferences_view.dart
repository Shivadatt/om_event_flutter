import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

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
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool whatsappEnabled = true;

  bool bookingEnabled = true;
  bool paymentEnabled = true;
  bool quotationEnabled = true;
  bool reviewEnabled = true;
  bool offerEnabled = true;
  bool supportEnabled = true;
  bool reminderEnabled = true;
  bool marketingEnabled = false;
  bool newsletterEnabled = false;

  bool dndEnabled = false;
  String quietHoursStart = '22:00';
  String quietHoursEnd = '07:00';
  bool dailyDigestEnabled = false;

  bool isLoading = true;
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
            offerEnabled = data['offerEnabled'] ?? true;
            supportEnabled = data['supportEnabled'] ?? true;
            reminderEnabled = data['reminderEnabled'] ?? true;
            marketingEnabled = data['marketingEnabled'] ?? false;
            newsletterEnabled = data['newsletterEnabled'] ?? false;
            dndEnabled = data['dndEnabled'] ?? false;
            quietHoursStart = data['quietHoursStart'] ?? '22:00';
            quietHoursEnd = data['quietHoursEnd'] ?? '07:00';
            dailyDigestEnabled = data['dailyDigestEnabled'] ?? false;
          });
        }
      }
    } catch (_) {
      // Fail silently
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    if (userId == null) return;
    try {
      setState(() => isLoading = true);
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
        'marketingEnabled': marketingEnabled,
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
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "COMMUNICATION KEYS",
                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                "Notification Preferences",
                style: GoogleFonts.italiana(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 1. Channel Controls Card
          _buildCard(
            title: "DELIVERY CHANNELS & FEEDS",
            children: [
              _buildSwitchListTile(
                title: "Push Notifications",
                subtitle: "Receive direct device and browser alerts",
                value: pushEnabled,
                onChanged: (val) => setState(() => pushEnabled = val),
              ),
              _buildSwitchListTile(
                title: "Email Messages",
                subtitle: "Receive custom HTML proposals and contract details",
                value: emailEnabled,
                onChanged: (val) => setState(() => emailEnabled = val),
              ),
              _buildSwitchListTile(
                title: "WhatsApp Alerts",
                subtitle: "Receive Meta template updates to your registered phone",
                value: whatsappEnabled,
                onChanged: (val) => setState(() => whatsappEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Quiet Hours Card
          _buildCard(
            title: "QUIET HOURS (DO NOT DISTURB)",
            children: [
              _buildSwitchListTile(
                title: "Enable Quiet Hours (DND)",
                subtitle: "Queue low-priority alerts during quiet hours",
                value: dndEnabled,
                onChanged: (val) => setState(() => dndEnabled = val),
              ),
              if (dndEnabled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF171411),
                        initialValue: quietHoursStart,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "DND Quiet Hours Start",
                          labelStyle: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: '20:00', child: Text("8:00 PM")),
                          DropdownMenuItem(value: '21:00', child: Text("9:00 PM")),
                          DropdownMenuItem(value: '22:00', child: Text("10:00 PM")),
                          DropdownMenuItem(value: '23:00', child: Text("11:00 PM")),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => quietHoursStart = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF171411),
                        initialValue: quietHoursEnd,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "DND Quiet Hours End",
                          labelStyle: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: '06:00', child: Text("6:00 AM")),
                          DropdownMenuItem(value: '07:00', child: Text("7:00 AM")),
                          DropdownMenuItem(value: '08:00', child: Text("8:00 AM")),
                          DropdownMenuItem(value: '09:00', child: Text("9:00 AM")),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => quietHoursEnd = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              _buildSwitchListTile(
                title: "Receive Daily Digest Summaries",
                subtitle: "Batch low-priority inquiries into a single daily briefing",
                value: dailyDigestEnabled,
                onChanged: (val) => setState(() => dailyDigestEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Event Toggles Card
          _buildCard(
            title: "TRANSACTION ALERTS & CATEGORIES",
            children: [
              _buildCheckboxTile("Quotation Proposal Updates", quotationEnabled, (val) => setState(() => quotationEnabled = val!)),
              _buildCheckboxTile("Support Ticket Replies", supportEnabled, (val) => setState(() => supportEnabled = val!)),
              _buildCheckboxTile("Design Review Requests", reviewEnabled, (val) => setState(() => reviewEnabled = val!)),
              _buildCheckboxTile("Exclusive Campaigns & Promos", offerEnabled, (val) => setState(() => offerEnabled = val!)),
              _buildCheckboxTile("Studio Newsletters", newsletterEnabled, (val) => setState(() => newsletterEnabled = val!)),
            ],
          ),
          const SizedBox(height: 36),

          // Submit Button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text("SAVE NOTIFICATION SETTINGS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF091210),
                minimumSize: const Size(280, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                elevation: 4,
              ),
              onPressed: _savePreferences,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF171411),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1AD4AF37)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchListTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 11)),
      value: value,
      activeThumbColor: const Color(0xFFD4AF37),
      activeTrackColor: const Color(0xFF3A2B18),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white12,
      onChanged: onChanged,
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: const Color(0x33D4AF37)),
      child: CheckboxListTile(
        title: Text(label, style: AppTheme.sansBody(fontSize: 13, color: Colors.white70)),
        value: value,
        activeColor: const Color(0xFFD4AF37),
        checkColor: const Color(0xFF091210),
        contentPadding: EdgeInsets.zero,
        onChanged: onChanged,
      ),
    );
  }
}
