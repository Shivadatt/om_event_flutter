import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';

/// Renders the top header bar of the proposal editor with locks status and Super Admin unlock triggers.
class EditorHeaderBar extends StatelessWidget {
  final Quotation quotation;
  final AdminController controller;
  final AuthController authController;
  final bool isPermLocked;
  final bool isFinLocked;
  final bool isSuperAdmin;
  final Color paperColor;
  final Color inkColor;
  final Color lineColor;
  final Color goldColor;

  const EditorHeaderBar({
    super.key,
    required this.quotation,
    required this.controller,
    required this.authController,
    required this.isPermLocked,
    required this.isFinLocked,
    required this.isSuperAdmin,
    required this.paperColor,
    required this.inkColor,
    required this.lineColor,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: paperColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "EDIT PROPOSAL",
                    style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 2),
                  ),
                  if (isPermLocked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        "PERMANENTLY LOCKED",
                        style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ),
                  ] else if (isFinLocked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Text(
                        "FINANCIAL LOCK ACTIVE",
                        style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.warning),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Quotation: ${quotation.publicId.toUpperCase()}",
                style: AppTheme.serifHeader(fontSize: 22, fontWeight: FontWeight.bold, color: inkColor),
              ),
            ],
          ),
          Row(
            children: [
              if (isPermLocked) ...[
                if (isSuperAdmin)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    icon: const Icon(Icons.lock_open_rounded, size: 16),
                    label: const Text("Unlock"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          backgroundColor: paperColor,
                          title: const Text("Unlock Quotation"),
                          content: const Text("Are you sure you want to unlock this permanently locked quotation? This action will create an audit log and remove all editing restrictions."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                Navigator.pop(dialogCtx);
                                await controller.unlockQuotation(
                                  quotation.id,
                                  authController.rxAdminRole.value?.name ?? 'Super Admin',
                                );
                                navigator.pop();
                              },
                              child: const Text("Confirm Unlock"),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Tooltip(
                    message: "Only Super Admins can unlock confirmed booking proposals.",
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: inkColor.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          "Only Super Admin can unlock",
                          style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
