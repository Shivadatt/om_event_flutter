import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

/// Manages notification templates from the [notification_templates] collection.
/// Each document stores: eventType, subject, body (with {{variable}} placeholders),
/// channel (email/sms/push), isActive.
class ManageNotificationTemplatesScreen extends StatefulWidget {
  const ManageNotificationTemplatesScreen({super.key});

  @override
  State<ManageNotificationTemplatesScreen> createState() =>
      _ManageNotificationTemplatesScreenState();
}

class _ManageNotificationTemplatesScreenState
    extends State<ManageNotificationTemplatesScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<_TemplateData> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final snap = await _firestore
          .collection(AppCollections.notificationTemplates)
          .orderBy('eventType')
          .get();
      setState(() {
        _templates = snap.docs.map((doc) {
          final data = doc.data();
          return _TemplateData(
            id: doc.id,
            eventType: data['eventType'] ?? doc.id,
            subject: data['subject'] ?? '',
            body: data['body'] ?? '',
            channel: data['channel'] ?? 'email',
            isActive: data['isActive'] ?? true,
          );
        }).toList();
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openTemplateDialog({_TemplateData? existing}) {
    Get.dialog(
      _TemplateDialog(
        existing: existing,
        onSave: (data) async {
          try {
            if (existing != null) {
              await _firestore
                  .collection(AppCollections.notificationTemplates)
                  .doc(existing.id)
                  .update({
                'eventType': data.eventType,
                'subject': data.subject,
                'body': data.body,
                'channel': data.channel,
                'isActive': data.isActive,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } else {
              await _firestore
                  .collection(AppCollections.notificationTemplates)
                  .add({
                'eventType': data.eventType,
                'subject': data.subject,
                'body': data.body,
                'channel': data.channel,
                'isActive': data.isActive,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
            Get.snackbar('Saved', 'Template saved successfully.',
                snackPosition: SnackPosition.BOTTOM);
            _loadTemplates();
          } catch (e) {
            Get.snackbar('Error', 'Failed to save template: $e');
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _toggleActive(_TemplateData t) async {
    try {
      await _firestore
          .collection(AppCollections.notificationTemplates)
          .doc(t.id)
          .update({'isActive': !t.isActive});
      _loadTemplates();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e');
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
        title: Text('NOTIFICATION TEMPLATES',
            style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_outlined, color: AppColors.primaryAccent),
            tooltip: 'Add Template',
            onPressed: () => _openTemplateDialog(),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : _templates.isEmpty
              ? _buildEmpty(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _TemplateTile(
                    template: _templates[i],
                    isDark: isDark,
                    onEdit: () => _openTemplateDialog(existing: _templates[i]),
                    onToggle: () => _toggleActive(_templates[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
          const SizedBox(height: 16),
          Text('No notification templates found.\nTap + to create one.',
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted)),
        ],
      ),
    );
  }
}

// ── Template Data ─────────────────────────────────────────────────────────────

class _TemplateData {
  final String id;
  final String eventType;
  final String subject;
  final String body;
  final String channel;
  final bool isActive;

  const _TemplateData({
    required this.id,
    required this.eventType,
    required this.subject,
    required this.body,
    required this.channel,
    required this.isActive,
  });
}

// ── Template Tile ─────────────────────────────────────────────────────────────

class _TemplateTile extends StatelessWidget {
  final _TemplateData template;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _TemplateTile({
    required this.template,
    required this.isDark,
    required this.onEdit,
    required this.onToggle,
  });

  Color get _channelColor {
    switch (template.channel) {
      case 'sms':
        return const Color(0xFF4CAF50);
      case 'push':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: template.isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2420) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: template.isActive
                ? AppColors.primaryAccent.withValues(alpha: 0.25)
                : Colors.red.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Channel badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _channelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _channelColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    template.channel.toUpperCase(),
                    style: AppTheme.sansBody(
                        fontSize: 10, fontWeight: FontWeight.bold, color: _channelColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    template.eventType,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Active status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (template.isActive
                            ? const Color(0xFF4CAF50)
                            : Colors.red)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    template.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: template.isActive ? const Color(0xFF4CAF50) : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle
                IconButton(
                  icon: Icon(
                    template.isActive
                        ? Icons.toggle_on_outlined
                        : Icons.toggle_off_outlined,
                    size: 20,
                    color: template.isActive
                        ? const Color(0xFF4CAF50)
                        : Colors.red.shade400,
                  ),
                  onPressed: onToggle,
                  tooltip: template.isActive ? 'Deactivate' : 'Activate',
                ),
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.primaryAccent),
                  onPressed: onEdit,
                  tooltip: 'Edit Template',
                ),
              ],
            ),
            if (template.subject.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Subject: ${template.subject}',
                style: AppTheme.sansBody(
                  fontSize: 12,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              template.body,
              style: AppTheme.sansBody(
                fontSize: 12,
                color: (isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B))
                    .withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Template Dialog ───────────────────────────────────────────────────────────

class _TemplateDialog extends StatefulWidget {
  final _TemplateData? existing;
  final Future<void> Function(_TemplateData) onSave;

  const _TemplateDialog({this.existing, required this.onSave});

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _eventTypeCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _bodyCtrl;
  late String _channel;
  late bool _isActive;
  bool _isSaving = false;
  bool _showPreview = false;

  static const _channels = ['email', 'sms', 'push'];
  static const _variables = [
    '{{customerName}}',
    '{{bookingId}}',
    '{{eventDate}}',
    '{{eventType}}',
    '{{packageName}}',
    '{{amount}}',
    '{{businessName}}',
    '{{status}}',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _eventTypeCtrl = TextEditingController(text: e?.eventType ?? '');
    _subjectCtrl = TextEditingController(text: e?.subject ?? '');
    _bodyCtrl = TextEditingController(text: e?.body ?? '');
    _channel = e?.channel ?? 'email';
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _eventTypeCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  String _renderPreview(String text) {
    return text
        .replaceAll('{{customerName}}', 'Priya Mehta')
        .replaceAll('{{bookingId}}', 'BK-2026-001')
        .replaceAll('{{eventDate}}', '25 October 2026')
        .replaceAll('{{eventType}}', 'Wedding Decoration')
        .replaceAll('{{packageName}}', 'Premium Royale')
        .replaceAll('{{amount}}', '₹45,000')
        .replaceAll('{{businessName}}', 'Om Events & Decorators')
        .replaceAll('{{status}}', 'Confirmed');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      child: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'EDIT TEMPLATE' : 'NEW TEMPLATE',
                        style: AppTheme.serifHeader(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    // Preview toggle
                    TextButton.icon(
                      icon: Icon(
                        _showPreview ? Icons.edit_outlined : Icons.preview_outlined,
                        size: 16,
                        color: AppColors.primaryAccent,
                      ),
                      label: Text(
                        _showPreview ? 'EDIT' : 'PREVIEW',
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      onPressed: () => setState(() => _showPreview = !_showPreview),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Channel selector
                Row(
                  children: _channels.map((ch) {
                    final isSelected = _channel == ch;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _channel = ch),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : (isDark ? const Color(0xFF1A2420) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryAccent
                                  : AppColors.primaryAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            ch.toUpperCase(),
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF091210)
                                  : (isDark
                                      ? const Color(0xFFF7F2EA)
                                      : const Color(0xFF0F0D0B)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                _field('Event Type *', _eventTypeCtrl, isDark,
                    hint: 'e.g. booking_confirmed, payment_received',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),

                if (_channel == 'email')
                  _field('Subject', _subjectCtrl, isDark,
                      hint: 'Email subject line'),

                const SizedBox(height: 4),

                // Variable chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _variables
                      .map((v) => GestureDetector(
                            onTap: () {
                              final pos = _bodyCtrl.selection.baseOffset;
                              final text = _bodyCtrl.text;
                              final newText = pos < 0
                                  ? text + v
                                  : text.substring(0, pos) + v + text.substring(pos);
                              _bodyCtrl.value = TextEditingValue(
                                text: newText,
                                selection:
                                    TextSelection.collapsed(offset: pos < 0 ? newText.length : pos + v.length),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(v,
                                  style: AppTheme.sansBody(
                                      fontSize: 10,
                                      color: AppColors.primaryAccent)),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 10),

                if (_showPreview)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PREVIEW',
                            style: AppTheme.sansBody(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryAccent,
                                letterSpacing: 1)),
                        const SizedBox(height: 8),
                        if (_subjectCtrl.text.isNotEmpty) ...[
                          Text(
                            'Subject: ${_renderPreview(_subjectCtrl.text)}',
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF7F2EA)
                                  : const Color(0xFF0F0D0B),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          _renderPreview(_bodyCtrl.text),
                          style: AppTheme.sansBody(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFFF7F2EA)
                                : const Color(0xFF0F0D0B),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextFormField(
                    controller: _bodyCtrl,
                    maxLines: 8,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Message Body *',
                      labelStyle: AppTheme.sansBody(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      hintText: 'Use {{variable}} placeholders. Tap the chips above to insert.',
                      hintStyle: AppTheme.sansBody(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColors.primaryAccent.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColors.primaryAccent.withValues(alpha: 0.2)),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                const SizedBox(height: 16),

                // Active switch
                Row(
                  children: [
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Text('Active (sends notifications when enabled)',
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                        )),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSaving ? null : Get.back,
                        child: const Text('CANCEL')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: const Color(0xFF091210),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? 'SAVE CHANGES' : 'CREATE TEMPLATE',
                              style: AppTheme.sansBody(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        style: AppTheme.sansBody(
          fontSize: 13,
          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTheme.sansBody(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          hintStyle: AppTheme.sansBody(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_TemplateData(
        id: widget.existing?.id ?? '',
        eventType: _eventTypeCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        channel: _channel,
        isActive: _isActive,
      ));
      Get.back();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
