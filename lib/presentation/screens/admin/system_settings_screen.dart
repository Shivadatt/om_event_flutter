import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/repositories/admin_repository.dart';
import 'widgets/settings_general_tab.dart';
import 'widgets/settings_contact_tab.dart';
import 'widgets/settings_social_tab.dart';
import 'widgets/settings_branches_tab.dart';

/// Screen configured to manage and edit business listing settings and branch registrations.
class SystemSettingsScreen extends StatefulWidget {
  /// Creates a [SystemSettingsScreen] instance.
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _adminRepository = Get.find<AdminRepository>();
  final _authController = Get.find<AuthController>();

  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _faviconUrlCtrl = TextEditingController();

  final _supportEmailCtrl = TextEditingController();
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  final _instagramCtrl = TextEditingController();
  final _instagramKadiCtrl = TextEditingController();
  final _instagramThangadhCtrl = TextEditingController();

  List<Map<String, dynamic>> _branches = [];
  int _activeTab = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _taglineCtrl,
      _descriptionCtrl,
      _logoUrlCtrl,
      _faviconUrlCtrl,
      _supportEmailCtrl,
      _phone1Ctrl,
      _phone2Ctrl,
      _whatsappCtrl,
      _emergencyPhoneCtrl,
      _instagramCtrl,
      _instagramKadiCtrl,
      _instagramThangadhCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminRepository.getSettings();
      _nameCtrl.text = data['business_name'] ?? 'Om Events & Decorators';
      _taglineCtrl.text = data['business_tagline'] ?? 'Luxury Event Designs';
      _descriptionCtrl.text =
          data['company_description'] ??
          'Creative styling, design, and execution for premium weddings.';
      _logoUrlCtrl.text = data['logo'] ?? '';
      _faviconUrlCtrl.text = data['favicon'] ?? '';

      _supportEmailCtrl.text =
          data['support_email'] ??
          data['email'] ??
          'omeventsanddecorators@gmail.com';
      _phone1Ctrl.text =
          data['primary_phone'] ?? data['phone'] ?? '+91 95121 49944';
      _phone2Ctrl.text = data['secondary_phone'] ?? '+91 93135 13156';
      _whatsappCtrl.text = data['whatsapp_number'] ?? '';
      _emergencyPhoneCtrl.text = data['emergency_number'] ?? '';

      _instagramCtrl.text =
          data['instagram'] ?? 'https://instagram.com/om_events';
      _instagramKadiCtrl.text = data['instagram_kadi'] ?? '';
      _instagramThangadhCtrl.text = data['instagram_thangadh'] ?? '';

      if (data['branches'] != null) {
        _branches = List<Map<String, dynamic>>.from(
          (data['branches'] as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      } else {
        _branches = [
          {
            'name': 'Kadi (Medha)',
            'address_line': 'Medha (kadi-kalyanpura road)',
            'city': 'Kadi',
            'state': 'Gujarat',
            'country': 'India',
            'pin_code': '382715',
            'phone': '+91 95121 49944',
            'email': 'omeventsanddecorators@gmail.com',
            'instagram_url': 'https://instagram.com/kadi_branch',
            'is_active': true,
            'display_order': 0,
          },
          {
            'name': 'Thangadh',
            'address_line': 'Thangadh(Surendranagar)',
            'city': 'Thangadh',
            'state': 'Gujarat',
            'country': 'India',
            'phone': '+91 93135 13156',
            'email': 'omeventsanddecorators@gmail.com',
            'instagram_url': 'https://instagram.com/thangadh_branch',
            'is_active': true,
            'display_order': 1,
          },
        ];
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load settings: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await _adminRepository.saveSettings({
        'business_name': _nameCtrl.text,
        'business_tagline': _taglineCtrl.text,
        'company_description': _descriptionCtrl.text,
        'logo': _logoUrlCtrl.text,
        'favicon': _faviconUrlCtrl.text,
        'support_email': _supportEmailCtrl.text,
        'primary_phone': _phone1Ctrl.text,
        'secondary_phone': _phone2Ctrl.text,
        'whatsapp_number': _whatsappCtrl.text,
        'emergency_number': _emergencyPhoneCtrl.text,
        'instagram': _instagramCtrl.text,
        'instagram_kadi': _instagramKadiCtrl.text,
        'instagram_thangadh': _instagramThangadhCtrl.text,
        'branches': _branches,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': _authController.rxAdminRole.value?.email ?? 'system',
      });
      Get.snackbar("Success", "Business information updated successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to save settings: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addBranch() {
    setState(() {
      _branches.add({
        'name': 'New Branch',
        'address_line': '',
        'city': '',
        'state': 'Gujarat',
        'country': 'India',
        'phone': '',
        'email': '',
        'instagram_url': '',
        'is_active': true,
        'display_order': _branches.length,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1714),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC8A26A)),
          onPressed: () => Get.offAllNamed(AppRoutes.adminDashboard),
        ),
        title: Text(
          "BUSINESS INFORMATION CONFIGURATOR",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFC8A26A)),
                ),
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D1915),
                      border: Border(
                        right: BorderSide(color: Color(0xFF254235)),
                      ),
                    ),
                    child: ListView(
                      children: [
                        _tabItem(0, "Business Info", Icons.business_outlined),
                        _tabItem(
                          1,
                          "Contact Details",
                          Icons.contact_mail_outlined,
                        ),
                        _tabItem(2, "Branches", Icons.storefront_outlined),
                        _tabItem(3, "Social Links", Icons.share_outlined),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IndexedStack(
                            index: _activeTab,
                            children: [
                              SettingsGeneralTab(
                                nameCtrl: _nameCtrl,
                                taglineCtrl: _taglineCtrl,
                                descriptionCtrl: _descriptionCtrl,
                                logoUrlCtrl: _logoUrlCtrl,
                                faviconUrlCtrl: _faviconUrlCtrl,
                              ),
                              SettingsContactTab(
                                supportEmailCtrl: _supportEmailCtrl,
                                phone1Ctrl: _phone1Ctrl,
                                phone2Ctrl: _phone2Ctrl,
                                whatsappCtrl: _whatsappCtrl,
                                emergencyPhoneCtrl: _emergencyPhoneCtrl,
                              ),
                              SettingsBranchesTab(
                                branches: _branches,
                                onAdd: _addBranch,
                                onRemove:
                                    (idx) =>
                                        setState(() => _branches.removeAt(idx)),
                                onChanged: () => setState(() {}),
                              ),
                              SettingsSocialTab(
                                instagramCtrl: _instagramCtrl,
                                instagramKadiCtrl: _instagramKadiCtrl,
                                instagramThangadhCtrl: _instagramThangadhCtrl,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8A26A),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text(
                              "SAVE CONFIGURATION",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    final isActive = _activeTab == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFFC8A26A) : const Color(0xFFA4A9A7),
        size: 18,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFFA4A9A7),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      tileColor: isActive ? const Color(0xFF162822) : Colors.transparent,
      onTap: () => setState(() => _activeTab = index),
    );
  }
}
