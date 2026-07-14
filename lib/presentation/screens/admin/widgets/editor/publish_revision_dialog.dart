import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_input.dart';
import '../../../../controllers/admin_controller.dart';

/// Modal dialog confirming revision description notes and invoking the publish operation.
class PublishRevisionDialog extends StatefulWidget {
  final AdminController controller;
  final DateTime selectedDate;
  final TextEditingController timeController;
  final TextEditingController locController;
  final TextEditingController notesController;
  final TextEditingController internalNotesController;
  final TextEditingController adminMessageController;
  final TextEditingController operationalNotesController;
  final TextEditingController bookingDetailsController;
  final TextEditingController staffAssignmentController;
  final TextEditingController logisticsController;
  final NavigatorState editorNavigator;

  const PublishRevisionDialog({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.timeController,
    required this.locController,
    required this.notesController,
    required this.internalNotesController,
    required this.adminMessageController,
    required this.operationalNotesController,
    required this.bookingDetailsController,
    required this.staffAssignmentController,
    required this.logisticsController,
    required this.editorNavigator,
  });

  @override
  State<PublishRevisionDialog> createState() => _PublishRevisionDialogState();
}

class _PublishRevisionDialogState extends State<PublishRevisionDialog> {
  final _reasonCtrl = TextEditingController(text: "Updated decorations & price adjustment");
  bool _isPublishing = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Dialog(
      backgroundColor: paperColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PUBLISH REVISED PROPOSAL",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: "Revision Reason (Internal/Client visible)",
              placeholder: "e.g. Added flower arches",
              controller: _reasonCtrl,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isPublishing ? null : () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: inkColor.withValues(alpha: 0.6))),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A77E),
                    foregroundColor: const Color(0xFF091210),
                  ),
                  onPressed: _isPublishing ? null : () async {
                          if (_reasonCtrl.text.trim().isEmpty) return;

                          final nav = Navigator.of(context);
                          setState(() => _isPublishing = true);

                          try {
                            final success = await widget.controller.publishActiveRevision(
                              eventDate: widget.selectedDate,
                              eventTime: widget.timeController.text,
                              location: widget.locController.text,
                              notes: widget.notesController.text,
                              internalNotes: widget.internalNotesController.text,
                              adminMessage: widget.adminMessageController.text,
                              revisionReason: _reasonCtrl.text.trim(),
                              operationalNotes: widget.operationalNotesController.text,
                              bookingDetails: widget.bookingDetailsController.text,
                              staffAssignment: widget.staffAssignmentController.text,
                              logistics: widget.logisticsController.text,
                            );

                            if (success) {
                              nav.pop(); // Close revision dialog
                              if (widget.editorNavigator.canPop()) {
                                widget.editorNavigator.pop(); // Close editor dialog
                              }
                            } else {
                              setState(() => _isPublishing = false);
                            }
                          } catch (_) {
                            setState(() => _isPublishing = false);
                          }
                        },
                  child: _isPublishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF091210),
                          ),
                        )
                      : const Text("Publish"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
