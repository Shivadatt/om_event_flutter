import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/seeder_controller.dart';
import 'widgets/admin_back_button.dart';

class SeederScreen extends StatelessWidget {
  const SeederScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SeederController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "FIREBASE MIGRATION SEEDER",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  controller.isCompleted.value
                      ? Icons.check_circle_outline
                      : (controller.errorMessage.isNotEmpty
                          ? Icons.error_outline
                          : Icons.cloud_sync_outlined),
                  size: 80,
                  color:
                      controller.isCompleted.value
                          ? Colors.green
                          : (controller.errorMessage.isNotEmpty
                              ? Colors.red
                              : const Color(0xFFC9A77E)),
                ),
                const SizedBox(height: 24),
                Text(
                  controller.isCompleted.value
                      ? "MIGRATION COMPLETED"
                      : "Firestore & Supabase Seeder",
                  textAlign: TextAlign.center,
                  style: AppTheme.serifHeader(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "This tool resets Firestore collection documents, uploads local portfolio media to Supabase Storage, and maps references to public URLs.",
                  textAlign: TextAlign.center,
                  style: AppTheme.sansBody(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Progress Bar
                if (controller.isMigrating.value ||
                    controller.isCompleted.value) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: controller.progressPercent.value,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      color: const Color(0xFFC9A77E),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${(controller.progressPercent.value * 100).toInt()}%",
                    textAlign: TextAlign.right,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC9A77E),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Status Log Output
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161E1B) : Colors.grey[100],
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.statusMessage.value,
                    textAlign: TextAlign.center,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color:
                          controller.errorMessage.isNotEmpty
                              ? Colors.red
                              : null,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                 if (!controller.isMigrating.value) ...[
                  ElevatedButton(
                    onPressed: () => controller.runMigration(force: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A77E),
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      controller.isCompleted.value
                          ? "FORCE RE-SEED DATABASE"
                          : (controller.errorMessage.isNotEmpty
                              ? "RETRY SEEDING"
                              : "START SEEDER"),
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.runSeedCategories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3D31),
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "SEED CATEGORIES ONLY",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC9A77E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.runSeedServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3D31),
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "SEED SERVICES ONLY",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC9A77E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.runFixRelationships,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3D31),
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "FIX RELATIONSHIPS ONLY",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC9A77E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.runFullMigrationManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A77E),
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "RUN FULL MIGRATION",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
