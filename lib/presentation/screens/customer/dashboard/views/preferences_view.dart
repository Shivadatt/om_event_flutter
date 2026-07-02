import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_collections.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        final doc = await _firestore
            .collection(AppCollections.customerNotificationPreferences)
            .doc(userId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
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
      await _firestore
          .collection(AppCollections.customerNotificationPreferences)
          .doc(userId)
          .set({
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
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        "Preferences Saved",
        "Your notification channel configurations have been updated.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF12271F),
        colorText: const Color(0xFFC9A77E),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to save: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A77E)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notification Preferences", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 8),
          Text("Granular control over delivery channels, transactional alerts, and quiet hours.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 24),

          // 1. Channel Controls
          _buildCard(
            title: "DELIVERY CHANNELS TABS",
            children: [
              SwitchListTile(
                title: const Text("Push Notifications", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text("Receive direct device and browser alerts", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: pushEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => pushEnabled = val),
              ),
              SwitchListTile(
                title: const Text("Email Messages", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text("Receive custom HTML proposals and receipt copies", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: emailEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => emailEnabled = val),
              ),
              SwitchListTile(
                title: const Text("WhatsApp Alerts", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text("Receive official Meta template updates to your registered phone", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: whatsappEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => whatsappEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Quiet Hours (DND) Panel
          _buildCard(
            title: "QUIET HOURS (DO NOT DISTURB)",
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Enable Quiet Hours (DND)", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text("Queue low-priority alerts during quiet hours", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: dndEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => dndEnabled = val),
              ),
              if (dndEnabled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF12271F),
                        value: quietHoursStart,
                        decoration: const InputDecoration(
                          labelText: "DND Quiet Hours Start",
                          labelStyle: TextStyle(color: Color(0xFFC9A77E), fontSize: 11),
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
                        dropdownColor: const Color(0xFF12271F),
                        value: quietHoursEnd,
                        decoration: const InputDecoration(
                          labelText: "DND Quiet Hours End",
                          labelStyle: TextStyle(color: Color(0xFFC9A77E), fontSize: 11),
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
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Receive Daily Digest Summaries", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text("Batch low-priority inquiries into a single daily briefing", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: dailyDigestEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => dailyDigestEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Event Toggles
          _buildCard(
            title: "CRM TRANSACTION EVENTS",
            children: [
              _buildCheckboxTile("Booking Status Updates", bookingEnabled, (val) => setState(() => bookingEnabled = val!)),
              _buildCheckboxTile("Payment Verifications", paymentEnabled, (val) => setState(() => paymentEnabled = val!)),
              _buildCheckboxTile("Quotation Proposal Toggles", quotationEnabled, (val) => setState(() => quotationEnabled = val!)),
              _buildCheckboxTile("Support Ticket Reply Notifications", supportEnabled, (val) => setState(() => supportEnabled = val!)),
              _buildCheckboxTile("Review Requests", reviewEnabled, (val) => setState(() => reviewEnabled = val!)),
              _buildCheckboxTile("Dynamic Booking Reminders", reminderEnabled, (val) => setState(() => reminderEnabled = val!)),
              _buildCheckboxTile("Exclusive Offers & Promos", offerEnabled, (val) => setState(() => offerEnabled = val!)),
              _buildCheckboxTile("Marketing Campaigns", marketingEnabled, (val) => setState(() => marketingEnabled = val!)),
              _buildCheckboxTile("Newsletter Digests", newsletterEnabled, (val) => setState(() => newsletterEnabled = val!)),
            ],
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A77E),
              foregroundColor: const Color(0xFF091210),
              minimumSize: const Size(200, 50),
            ),
            onPressed: _savePreferences,
            child: const Text("Save Preferences"),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), letterSpacing: 1.5)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      value: value,
      activeColor: const Color(0xFFC9A77E),
      checkColor: const Color(0xFF091210),
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}
