import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

/// Manages Service Area branches stored in settings/business_details.
/// Branches include coverage zones, contact info, and map URLs.
class ManageServiceAreaScreen extends StatefulWidget {
  const ManageServiceAreaScreen({super.key});

  @override
  State<ManageServiceAreaScreen> createState() => _ManageServiceAreaScreenState();
}

class _ManageServiceAreaScreenState extends State<ManageServiceAreaScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final doc = await _firestore
          .collection(AppCollections.settings)
          .doc('business_details')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final rawBranches = data['branches'];
        if (rawBranches is List) {
          setState(() {
            _branches = List<Map<String, dynamic>>.from(
              rawBranches.map((e) => Map<String, dynamic>.from(e as Map)),
            );
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load service areas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBranches() async {
    setState(() => _isSaving = true);
    try {
      await _firestore
          .collection(AppCollections.settings)
          .doc('business_details')
          .set({
        'branches': _branches,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Saved', 'Service areas updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addBranch() {
    setState(() => _branches.add({
          'id': 'branch_${DateTime.now().millisecondsSinceEpoch}',
          'branchName': '',
          'branchManager': '',
          'phoneNumber': '',
          'whatsapp': '',
          'email': '',
          'fullAddress': '',
          'googleMapUrl': '',
          'latitude': '',
          'longitude': '',
          'workingHours': '9:00 AM - 8:00 PM',
          'openingDays': 'Mon–Sat',
          'displayOrder': _branches.length + 1,
          'isActive': true,
          'instagram': '',
        }));
  }

  void _removeBranch(int index) {
    setState(() => _branches.removeAt(index));
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
        title: Text('SERVICE AREAS',
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
              label: Text('SAVE',
                  style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent)),
              onPressed: _saveBranches,
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: const Color(0xFF091210),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text('ADD AREA',
            style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: _addBranch,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : _branches.isEmpty
              ? _buildEmpty(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: _branches.length,
                  itemBuilder: (_, i) => _BranchCard(
                    index: i,
                    branch: _branches[i],
                    isDark: isDark,
                    onChanged: (updated) => setState(() => _branches[i] = updated),
                    onDelete: () => _removeBranch(i),
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined,
              size: 64, color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
          const SizedBox(height: 16),
          Text('No service areas configured yet.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted)),
        ],
      ),
    );
  }
}

class _BranchCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> branch;
  final bool isDark;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onDelete;

  const _BranchCard({
    required this.index,
    required this.branch,
    required this.isDark,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  late final Map<String, TextEditingController> _controllers;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _controllers = {
      'branchName': TextEditingController(text: b['branchName'] ?? ''),
      'branchManager': TextEditingController(text: b['branchManager'] ?? ''),
      'phoneNumber': TextEditingController(text: b['phoneNumber'] ?? ''),
      'whatsapp': TextEditingController(text: b['whatsapp'] ?? ''),
      'email': TextEditingController(text: b['email'] ?? ''),
      'fullAddress': TextEditingController(text: b['fullAddress'] ?? ''),
      'googleMapUrl': TextEditingController(text: b['googleMapUrl'] ?? ''),
      'workingHours': TextEditingController(text: b['workingHours'] ?? ''),
      'openingDays': TextEditingController(text: b['openingDays'] ?? ''),
    };
    for (final ctrl in _controllers.values) {
      ctrl.addListener(_notify);
    }
  }

  void _notify() {
    final updated = Map<String, dynamic>.from(widget.branch);
    for (final entry in _controllers.entries) {
      updated[entry.key] = entry.value.text;
    }
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.branch['isActive'] ?? true;
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1A2420) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.primaryAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _controllers['branchName']!.text.isNotEmpty
                            ? _controllers['branchName']!.text
                            : 'Service Area ${widget.index + 1}',
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? const Color(0xFFF7F2EA)
                              : const Color(0xFF0F0D0B),
                        ),
                      ),
                    ),
                    // Active toggle
                    Switch(
                      value: isActive,
                      onChanged: (v) {
                        final updated = Map<String, dynamic>.from(widget.branch)
                          ..['isActive'] = v;
                        widget.onChanged(updated);
                      },
                      activeThumbColor: AppColors.primaryAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade400),
                      onPressed: widget.onDelete,
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('branchName', 'Branch / Area Name', 'branchManager', 'Manager Name'),
                    const SizedBox(height: 12),
                    _row('phoneNumber', 'Phone Number', 'whatsapp', 'WhatsApp Number'),
                    const SizedBox(height: 12),
                    _row('email', 'Email', 'workingHours', 'Working Hours'),
                    const SizedBox(height: 12),
                    _row('openingDays', 'Opening Days', null, null),
                    const SizedBox(height: 12),
                    _field('fullAddress', 'Full Address', maxLines: 2),
                    const SizedBox(height: 12),
                    _field('googleMapUrl', 'Google Map Embed URL'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String key1, String label1, String? key2, String? label2) {
    return Row(
      children: [
        Expanded(child: _field(key1, label1)),
        if (key2 != null) ...[
          const SizedBox(width: 12),
          Expanded(child: _field(key2, label2!)),
        ],
      ],
    );
  }

  Widget _field(String key, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: _controllers[key],
      maxLines: maxLines,
      style: AppTheme.sansBody(
          fontSize: 13,
          color: widget.isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.sansBody(
            fontSize: 12,
            color: widget.isDark ? AppColors.darkMuted : AppColors.lightMuted),
        filled: true,
        fillColor: widget.isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
