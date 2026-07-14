import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/experience.dart';
import '../../../../controllers/admin_controller.dart';

/// Modal dialog displaying decoration items from the catalog for addition to the editor.
class ExperienceSelectorDialog extends StatelessWidget {
  final AdminController controller;

  const ExperienceSelectorDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Dialog(
      backgroundColor: paperColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SELECT DECORATION ITEM",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                letterSpacing: 1.5,
              ),
            ),
            const Divider(height: 20),
            Expanded(
              child: Obx(() {
                final experiences = controller.rxExperiences;
                if (experiences.isEmpty) {
                  return const Center(child: Text("No decoration items in catalog."));
                }
                return ListView.separated(
                  itemCount: experiences.length,
                  separatorBuilder: (context, index) => Divider(color: lineColor),
                  itemBuilder: (context, index) {
                    final Experience exp = experiences[index];
                    return ListTile(
                      title: Text(
                        exp.name,
                        style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Starting: ${AppFormatters.formatCurrency(exp.price)}",
                        style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.6)),
                      ),
                      trailing: const Icon(Icons.add_circle, color: Color(0xFFC9A77E)),
                      onTap: () {
                        controller.addEditorItem(exp);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
