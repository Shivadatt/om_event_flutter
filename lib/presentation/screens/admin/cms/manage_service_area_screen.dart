import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../controllers/business_details_controller.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

/// Manages Service Area coverage and activation states.
/// Branch identity records (names, contacts, addresses, coordinates)
/// are authoritatively maintained in Business Details (settings/business_info -> branches).
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

  Map<String, dynamic> _normalizeBranch(Map<String, dynamic> raw) {
    return {
      'id': raw['id']?.toString() ?? 'branch_${DateTime.now().millisecondsSinceEpoch}',
      'branchName': raw['branchName']?.toString() ?? raw['name']?.toString() ?? '',
      'branchManager': raw['branchManager']?.toString() ?? raw['manager']?.toString() ?? '',
      'phoneNumber': raw['phoneNumber']?.toString() ?? raw['phone']?.toString() ?? '',
      'whatsapp': raw['whatsapp']?.toString() ?? '',
      'email': raw['email']?.toString() ?? '',
      'fullAddress': raw['fullAddress']?.toString() ?? raw['address']?.toString() ?? '',
      'googleMapUrl': raw['googleMapUrl']?.toString() ?? raw['googleMaps']?.toString() ?? '',
      'latitude': raw['latitude']?.toString() ?? '',
      'longitude': raw['longitude']?.toString() ?? '',
      'workingHours': raw['workingHours']?.toString() ?? '9:00 AM - 8:00 PM',
      'openingDays': raw['openingDays']?.toString() ?? 'Mon–Sat',
      'displayOrder': (raw['displayOrder'] is int)
          ? raw['displayOrder']
          : (int.tryParse(raw['displayOrder']?.toString() ?? '1') ?? 1),
      'isActive': raw['isActive'] == null
          ? true
          : (raw['isActive'] == true || raw['isActive'] == 'true'),
      'instagram': raw['instagram']?.toString() ?? '',
      if (raw.containsKey('coverageRadius')) 'coverageRadius': raw['coverageRadius'],
      if (raw.containsKey('serviceNotes')) 'serviceNotes': raw['serviceNotes'],
    };
  }

  Future<void> _loadBranches() async {
    try {
      List<Map<String, dynamic>> loadedBranches = [];

      // 1. Primary SSOT: load from canonical settings/business_info
      final doc = await _firestore
          .collection(AppCollections.settings)
          .doc('business_info')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final source = data['published'] ?? data['draft'] ?? data;
        final rawBranches = source['branches'] ?? source['officeBranches'];
        if (rawBranches is List && rawBranches.isNotEmpty) {
          loadedBranches = rawBranches
              .whereType<Map>()
              .map((e) => _normalizeBranch(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      // 2. Fallback: if not found, load from legacy settings/business_details
      if (loadedBranches.isEmpty) {
        final legacyDoc = await _firestore
            .collection(AppCollections.settings)
            .doc('business_details')
            .get();
        if (legacyDoc.exists && legacyDoc.data() != null) {
          final rawBranches = legacyDoc.data()!['branches'];
          if (rawBranches is List) {
            loadedBranches = rawBranches
                .whereType<Map>()
                .map((e) => _normalizeBranch(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
      }

      setState(() {
        _branches = loadedBranches;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load service areas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBranches() async {
    setState(() => _isSaving = true);
    try {
      String getCity(String addr) {
        final parts = addr.split(',');
        if (parts.length >= 2) return parts[parts.length - 2].trim();
        return 'Office';
      }

      final legacyOfficeBranches = _branches.map((b) => {
        'id': b['id'],
        'name': b['branchName'],
        'address': b['fullAddress'],
        'city': getCity(b['fullAddress']?.toString() ?? ''),
        'state': 'Gujarat',
        'country': 'India',
        'pincode': '',
        'phone': b['phoneNumber'],
        'email': b['email'],
        'googleMaps': b['googleMapUrl'],
        'latitude': b['latitude'],
        'longitude': b['longitude'],
        'workingHours': b['workingHours'],
        'openingDays': b['openingDays'],
        'isPrimary': b['displayOrder'] == 1,
        'isActive': b['isActive'] ?? true,
        'instagram': b['instagram'] ?? '',
      }).toList();

      // 1. Save canonical branch list with updated active coverage to settings/business_info
      await _firestore
          .collection(AppCollections.settings)
          .doc('business_info')
          .set({
        'branches': _branches,
        'officeBranches': legacyOfficeBranches,
        'draft': {
          'branches': _branches,
          'officeBranches': legacyOfficeBranches,
        },
        'published': {
          'branches': _branches,
          'officeBranches': legacyOfficeBranches,
        },
        'meta': {
          'updatedAt': DateTime.now().toIso8601String(),
        },
      }, SetOptions(merge: true));

      // 2. Dual-write to settings/business_details for complete backward compatibility
      await _firestore
          .collection(AppCollections.settings)
          .doc('business_details')
          .set({
        'branches': _branches,
        'officeBranches': legacyOfficeBranches,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'Saved',
        'Service area coverage updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _navigateToBusinessDetailsBranches() {
    if (Get.isRegistered<BusinessDetailsController>()) {
      Get.find<BusinessDetailsController>().selectedIndex.value = 2; // Branches tab
    }
    Get.toNamed(AppRoutes.businessDetails);
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
        title: Text(
          'SERVICE AREAS & COVERAGE',
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.save_outlined, color: AppColors.primaryAccent),
              label: Text(
                'SAVE COVERAGE',
                style: AppTheme.sansBody(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAccent,
                ),
              ),
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
        icon: const Icon(Icons.add_business_outlined),
        label: Text(
          'ADD BRANCH IN BUSINESS DETAILS',
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: _navigateToBusinessDetailsBranches,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              children: [
                _buildSsotBanner(isDark),
                const SizedBox(height: 20),
                if (_branches.isEmpty)
                  _buildEmpty(isDark)
                else
                  ...List.generate(
                    _branches.length,
                    (i) => _BranchCoverageCard(
                      index: i,
                      branch: _branches[i],
                      isDark: isDark,
                      onToggleActive: (val) {
                        setState(() {
                          _branches[i]['isActive'] = val;
                        });
                      },
                      onEditInBusinessDetails: _navigateToBusinessDetailsBranches,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSsotBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : const Color(0xFFE8F2EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, color: AppColors.primaryAccent, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SINGLE SOURCE OF TRUTH: BRANCH IDENTITY',
                  style: GoogleFonts.italiana(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Branch names, managers, phone numbers, addresses, coordinates, and operating hours are centrally authored in Business Details. This screen controls live customer-facing service area coverage and activation without risking data drift or field loss.',
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.launch_outlined, size: 15),
                  label: Text(
                    'EDIT BRANCHES IN BUSINESS DETAILS',
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _navigateToBusinessDetailsBranches,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No branches configured in Business Details.\nCreate a branch in Business Details to activate it as a service area.',
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                fontSize: 14,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: const Color(0xFF091210),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('OPEN BUSINESS DETAILS'),
              onPressed: _navigateToBusinessDetailsBranches,
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCoverageCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> branch;
  final bool isDark;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEditInBusinessDetails;

  const _BranchCoverageCard({
    required this.index,
    required this.branch,
    required this.isDark,
    required this.onToggleActive,
    required this.onEditInBusinessDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = branch['isActive'] ?? true;
    final String branchName = (branch['branchName']?.toString().isNotEmpty ?? false)
        ? branch['branchName'].toString()
        : 'Service Area ${index + 1}';
    final String manager = branch['branchManager']?.toString() ?? '';
    final String phone = branch['phoneNumber']?.toString() ?? '';
    final String wa = branch['whatsapp']?.toString() ?? '';
    final String address = branch['fullAddress']?.toString() ?? '';
    final String hours = branch['workingHours']?.toString() ?? '';
    final String days = branch['openingDays']?.toString() ?? '';
    final String mapUrl = branch['googleMapUrl']?.toString() ?? '';

    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.65,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2420) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primaryAccent.withValues(alpha: 0.35)
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branchName,
                          style: AppTheme.sansBody(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF4EBA7A).withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isActive ? 'ACTIVE SERVICE COVERAGE' : 'COVERAGE DISABLED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? const Color(0xFF4EBA7A) : Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Active',
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Switch(
                        value: isActive,
                        onChanged: onToggleActive,
                        activeThumbColor: AppColors.primaryAccent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Canonical details presentation (read-only)
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  if (manager.isNotEmpty)
                    _detailItem(Icons.person_outline, 'Manager', manager, isDark),
                  if (phone.isNotEmpty)
                    _detailItem(Icons.phone_outlined, 'Phone', phone, isDark),
                  if (wa.isNotEmpty)
                    _detailItem(Icons.chat_bubble_outline, 'WhatsApp', wa, isDark),
                  if (hours.isNotEmpty || days.isNotEmpty)
                    _detailItem(
                      Icons.access_time,
                      'Hours',
                      '$hours ($days)',
                      isDark,
                    ),
                ],
              ),

              if (address.isNotEmpty) ...[
                const SizedBox(height: 10),
                _detailItem(Icons.home_outlined, 'Full Address', address, isDark),
              ],

              if (mapUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                _detailItem(Icons.map_outlined, 'Maps Link', mapUrl, isDark, maxLines: 1),
              ],

              const SizedBox(height: 16),
              // Direct navigation button to edit branch master identity in Business Details
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryAccent,
                      side: BorderSide(
                        color: AppColors.primaryAccent.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note, size: 16),
                    label: Text(
                      'EDIT IDENTITY IN BUSINESS DETAILS',
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: onEditInBusinessDetails,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value, bool isDark, {int maxLines = 2}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryAccent),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
