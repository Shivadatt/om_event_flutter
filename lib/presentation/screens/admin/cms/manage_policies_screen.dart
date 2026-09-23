import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

/// Manages Booking Policy, Cancellation Policy, Privacy Policy and T&C.
/// Data is stored in [LegalDetailsEntity] inside the 'business_details' settings doc.
class ManagePoliciesScreen extends StatefulWidget {
  const ManagePoliciesScreen({super.key});

  @override
  State<ManagePoliciesScreen> createState() => _ManagePoliciesScreenState();
}

class _ManagePoliciesScreenState extends State<ManagePoliciesScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  final _bookingCtrl = TextEditingController();
  final _cancellationCtrl = TextEditingController();
  final _privacyCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _refundCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  static const _tabs = [
    _PolicyTab(label: 'Booking', icon: Icons.book_outlined),
    _PolicyTab(label: 'Cancellation', icon: Icons.cancel_outlined),
    _PolicyTab(label: 'Refund', icon: Icons.currency_rupee_outlined),
    _PolicyTab(label: 'Privacy', icon: Icons.lock_outlined),
    _PolicyTab(label: 'T&C', icon: Icons.gavel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadPolicies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookingCtrl.dispose();
    _cancellationCtrl.dispose();
    _privacyCtrl.dispose();
    _termsCtrl.dispose();
    _refundCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPolicies() async {
    try {
      final doc = await _firestore
          .collection(AppCollections.settings)
          .doc('business_details')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final legal = Map<String, dynamic>.from(data['legal'] ?? {});
        _bookingCtrl.text = legal['termsAndConditions'] ?? '';
        _cancellationCtrl.text = legal['cancellationPolicy'] ?? '';
        _privacyCtrl.text = legal['privacyPolicy'] ?? '';
        _termsCtrl.text = legal['termsAndConditions'] ?? '';
        _refundCtrl.text = legal['refundPolicy'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load policies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePolicies() async {
    setState(() => _isSaving = true);
    try {
      await _firestore
          .collection(AppCollections.settings)
          .doc('business_details')
          .set({
        'legal': {
          'termsAndConditions': _termsCtrl.text.trim(),
          'cancellationPolicy': _cancellationCtrl.text.trim(),
          'privacyPolicy': _privacyCtrl.text.trim(),
          'refundPolicy': _refundCtrl.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Saved', 'Policies updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text('POLICIES & LEGAL',
            style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: textColor)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryAccent))),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.save_outlined, color: AppColors.primaryAccent),
              label: Text('SAVE ALL',
                  style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent)),
              onPressed: _savePolicies,
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          indicatorColor: AppColors.primaryAccent,
          tabs: _tabs
              .map((t) => Tab(
                    icon: Icon(t.icon, size: 16),
                    text: t.label,
                  ))
              .toList(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _PolicyEditor(
                  controller: _bookingCtrl,
                  isDark: isDark,
                  label: 'Booking Policy',
                  hint: 'Enter booking policy details...',
                ),
                _PolicyEditor(
                  controller: _cancellationCtrl,
                  isDark: isDark,
                  label: 'Cancellation Policy',
                  hint: 'Enter cancellation policy details...',
                ),
                _PolicyEditor(
                  controller: _refundCtrl,
                  isDark: isDark,
                  label: 'Refund Policy',
                  hint: 'Enter refund policy details...',
                ),
                _PolicyEditor(
                  controller: _privacyCtrl,
                  isDark: isDark,
                  label: 'Privacy Policy',
                  hint: 'Enter privacy policy details...',
                ),
                _PolicyEditor(
                  controller: _termsCtrl,
                  isDark: isDark,
                  label: 'Terms & Conditions',
                  hint: 'Enter terms and conditions...',
                ),
              ],
            ),
    );
  }
}

class _PolicyTab {
  final String label;
  final IconData icon;
  const _PolicyTab({required this.label, required this.icon});
}

class _PolicyEditor extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String label;
  final String hint;

  const _PolicyEditor({
    required this.controller,
    required this.isDark,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.serifHeader(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supports plain text and markdown formatting.',
            style: AppTheme.sansBody(
              fontSize: 11,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTheme.sansBody(
                fontSize: 13,
                color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.sansBody(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
