import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

/// Manages FAQ items stored in settings/homepage Firestore document.
/// The FAQs field is a list of {question, answer, isActive} maps.
class ManageFaqScreen extends StatefulWidget {
  const ManageFaqScreen({super.key});

  @override
  State<ManageFaqScreen> createState() => _ManageFaqScreenState();
}

class _ManageFaqScreenState extends State<ManageFaqScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _faqs = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final doc = await _firestore
          .collection(AppCollections.settings)
          .doc('homepage')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final source = data['published'] ?? data['draft'] ?? {};
        final rawFaqs = source['faqs'];
        if (rawFaqs is List) {
          setState(() {
            _faqs = List<Map<String, dynamic>>.from(
              rawFaqs.map((e) => Map<String, dynamic>.from(e as Map)),
            );
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load FAQs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFaqs() async {
    setState(() => _isSaving = true);
    try {
      final docRef = _firestore
          .collection(AppCollections.settings)
          .doc('homepage');
      final snap = await docRef.get();
      final currentData = snap.exists ? snap.data()! : <String, dynamic>{};
      final source = Map<String, dynamic>.from(
        currentData['published'] ?? currentData['draft'] ?? {},
      );
      source['faqs'] = _faqs;

      await docRef.set({
        'draft': source,
        'published': source,
        'meta': {
          'updatedAt': DateTime.now().toIso8601String(),
          'updatedBy': 'admin',
          'version': ((currentData['meta']?['version'] ?? 1) as int) + 1,
        },
      }, SetOptions(merge: true));

      Get.snackbar('Saved', 'FAQs updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save FAQs: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addFaq() {
    setState(() => _faqs.add({'question': '', 'answer': '', 'isActive': true}));
  }

  void _removeFaq(int index) {
    setState(() => _faqs.removeAt(index));
  }

  void _toggleActive(int index) {
    setState(() {
      _faqs[index] = {..._faqs[index], 'isActive': !(_faqs[index]['isActive'] ?? true)};
    });
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
        title: Text('FAQ MANAGEMENT',
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
              onPressed: _saveFaqs,
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
        icon: const Icon(Icons.add),
        label: Text('ADD FAQ', style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: _addFaq,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : _faqs.isEmpty
              ? _buildEmpty(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: _faqs.length,
                  itemBuilder: (_, i) => _FaqItemCard(
                    index: i,
                    faq: _faqs[i],
                    isDark: isDark,
                    onChanged: (updated) => setState(() => _faqs[i] = updated),
                    onDelete: () => _removeFaq(i),
                    onToggleActive: () => _toggleActive(i),
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined,
              size: 64, color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
          const SizedBox(height: 16),
          Text('No FAQ items yet. Tap + to add one.',
              style: AppTheme.sansBody(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted)),
        ],
      ),
    );
  }
}

class _FaqItemCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> faq;
  final bool isDark;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _FaqItemCard({
    required this.index,
    required this.faq,
    required this.isDark,
    required this.onChanged,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  State<_FaqItemCard> createState() => _FaqItemCardState();
}

class _FaqItemCardState extends State<_FaqItemCard> {
  late final TextEditingController _questionCtrl;
  late final TextEditingController _answerCtrl;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(text: widget.faq['question'] ?? '');
    _answerCtrl = TextEditingController(text: widget.faq['answer'] ?? '');
    _questionCtrl.addListener(_notify);
    _answerCtrl.addListener(_notify);
  }

  void _notify() {
    widget.onChanged({
      'question': _questionCtrl.text,
      'answer': _answerCtrl.text,
      'isActive': widget.faq['isActive'] ?? true,
    });
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.faq['isActive'] ?? true;
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1A2420) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primaryAccent.withValues(alpha: 0.25)
                : Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.index + 1}',
                    style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: isActive ? const Color(0xFF4CAF50) : Colors.red.shade400,
                  ),
                  onPressed: widget.onToggleActive,
                  tooltip: isActive ? 'Deactivate' : 'Activate',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete FAQ',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField('Question', _questionCtrl, widget.isDark),
            const SizedBox(height: 10),
            _buildField('Answer', _answerCtrl, widget.isDark, maxLines: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool isDark,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppTheme.sansBody(
          fontSize: 13,
          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.sansBody(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
        filled: true,
        fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
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
