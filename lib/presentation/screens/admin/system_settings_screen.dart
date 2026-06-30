import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/repositories/admin_repository.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _adminRepository = Get.find<AdminRepository>();
  final _authController = Get.find<AuthController>();

  // Tabs / Sections
  int _activeTab = 0;
  bool _isLoading = false;

  // Controllers: Business Info
  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _faviconUrlCtrl = TextEditingController();

  // Controllers: Contact Details
  final _supportEmailCtrl = TextEditingController();
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  // Controllers: Social links
  final _instagramCtrl = TextEditingController();
  final _instagramKadiCtrl = TextEditingController();
  final _instagramThangadhCtrl = TextEditingController();

  // Branches list representation (maps)
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminRepository.getSettings();

      // Load Business Info
      _nameCtrl.text = data['business_name'] ?? 'Om Events & Decorators';
      _taglineCtrl.text = data['business_tagline'] ?? 'Luxury Event Designs';
      _descriptionCtrl.text = data['company_description'] ?? 'Creative styling, design, and execution for premium weddings.';
      _logoUrlCtrl.text = data['logo'] ?? '';
      _faviconUrlCtrl.text = data['favicon'] ?? '';

      // Load Contact Details
      _supportEmailCtrl.text = data['support_email'] ?? data['email'] ?? 'omeventsanddecorators@gmail.com';
      _phone1Ctrl.text = data['primary_phone'] ?? data['phone'] ?? '+91 95121 49944';
      _phone2Ctrl.text = data['secondary_phone'] ?? '+91 93135 13156';
      _whatsappCtrl.text = data['whatsapp_number'] ?? '';
      _emergencyPhoneCtrl.text = data['emergency_number'] ?? '';

      // Load Social links
      _instagramCtrl.text = data['instagram'] ?? 'https://instagram.com/om_events';
      _instagramKadiCtrl.text = data['instagram_kadi'] ?? '';
      _instagramThangadhCtrl.text = data['instagram_thangadh'] ?? '';

      // Load Branches
      if (data['branches'] != null) {
        _branches = List<Map<String, dynamic>>.from(
          (data['branches'] as List).map((item) => Map<String, dynamic>.from(item)),
        );
      } else {
        // Seed default branches matching footer in provided screenshot
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
            'display_order': 0
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
            'display_order': 1
          }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC8A26A))))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inner vertical tabs
                Container(
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1915),
                    border: Border(right: BorderSide(color: Color(0xFF254235))),
                  ),
                  child: ListView(
                    children: [
                      _tabItem(0, "Business Info", Icons.business_outlined),
                      _tabItem(1, "Contact Details", Icons.contact_mail_outlined),
                      _tabItem(2, "Branches", Icons.storefront_outlined),
                      _tabItem(3, "Social Links", Icons.share_outlined),
                    ],
                  ),
                ),
                // Inner content layout
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IndexedStack(
                          index: _activeTab,
                          children: [
                            _buildBusinessInfoTab(),
                            _buildContactDetailsTab(),
                            _buildBranchesTab(),
                            _buildSocialTab(),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8A26A),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text("SAVE CONFIGURATION", style: TextStyle(fontWeight: FontWeight.bold)),
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
      leading: Icon(icon, color: isActive ? const Color(0xFFC8A26A) : const Color(0xFFA4A9A7), size: 18),
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

  Widget _buildBusinessInfoTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("BUSINESS NAME", _nameCtrl),
          const SizedBox(height: 16),
          _buildTextField("BUSINESS TAGLINE", _taglineCtrl),
          const SizedBox(height: 16),
          _buildTextField("COMPANY DESCRIPTION", _descriptionCtrl, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("LOGO PUBLIC URL", _logoUrlCtrl),
          const SizedBox(height: 16),
          _buildTextField("FAVICON PUBLIC URL", _faviconUrlCtrl),
        ],
      ),
    );
  }

  Widget _buildContactDetailsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("SUPPORT EMAIL", _supportEmailCtrl),
          const SizedBox(height: 16),
          _buildTextField("PRIMARY PHONE", _phone1Ctrl),
          const SizedBox(height: 16),
          _buildTextField("SECONDARY PHONE", _phone2Ctrl),
          const SizedBox(height: 16),
          _buildTextField("WHATSAPP INQUIRY NUMBER", _whatsappCtrl),
          const SizedBox(height: 16),
          _buildTextField("EMERGENCY DIRECT CONTACT", _emergencyPhoneCtrl),
        ],
      ),
    );
  }

  Widget _buildSocialTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("MAIN INSTAGRAM URL", _instagramCtrl),
          const SizedBox(height: 16),
          _buildTextField("INSTAGRAM KADI BRANCH", _instagramKadiCtrl),
          const SizedBox(height: 16),
          _buildTextField("INSTAGRAM THANGADH BRANCH", _instagramThangadhCtrl),
        ],
      ),
    );
  }

  Widget _buildBranchesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "REGISTERED BRANCH OFFICES",
              style: TextStyle(color: Color(0xFFC8A26A), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13),
            ),
            ElevatedButton.icon(
              onPressed: _addBranch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162822),
                foregroundColor: const Color(0xFFC8A26A),
                side: const BorderSide(color: Color(0xFF254235)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("ADD BRANCH"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_branches.isEmpty)
          const Text("No branches configured. Click ADD BRANCH to register corporate offices.", style: TextStyle(color: Colors.grey))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _branches.length,
            itemBuilder: (context, index) {
              final branch = _branches[index];
              return Card(
                color: const Color(0xFF162822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Color(0xFF254235)),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("BRANCH #${index + 1}: ${branch['name']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC8A26A))),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                _branches.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField("Branch Name", branch, 'name', index),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField("Phone", branch, 'phone', index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField("Email", branch, 'email', index),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField("Address Line", branch, 'address_line', index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField("City", branch, 'city', index),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField("Instagram URL", branch, 'instagram_url', index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBranchField(String label, Map<String, dynamic> branch, String field, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: branch[field] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF254235))),
          ),
          onChanged: (val) {
            _branches[index][field] = val;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC8A26A), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFF4F4F4)),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF254235))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFC8A26A))),
          ),
        ),
      ],
    );
  }
}
