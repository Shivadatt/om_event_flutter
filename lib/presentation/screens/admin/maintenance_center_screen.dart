import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/maintenance_controller.dart';

class MaintenanceCenterScreen extends StatelessWidget {
  const MaintenanceCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MaintenanceController());

    final operations = [
      'CustomerId Migration',
      'Relationship Repair',
      'Database Seeder',
      'Category Validation',
      'Item Validation',
      'Notification Repair',
      'Quotation Repair',
      'Version Repair',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Database Maintenance Center',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2B27),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E2B27)),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.rxIsProcessing.value) ...[
                _buildProgressCard(controller),
                const SizedBox(height: 24),
              ],
              const Text(
                'System Migration & Repairs',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2B27),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: operations.length,
                itemBuilder: (context, index) {
                  final op = operations[index];
                  return _buildOperationCard(context, controller, op);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressCard(MaintenanceController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.rxStatusMessage.value,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2B27),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                  onPressed: () => controller.cancelOperation(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: controller.rxProgress.value,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD3AD7B)),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Scanned', controller.rxScanned.value.toString()),
                _buildStatItem('Needs Update', controller.rxNeedsUpdate.value.toString()),
                _buildStatItem('Writes', controller.rxWrites.value.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2B27),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationCard(
    BuildContext context,
    MaintenanceController controller,
    String title,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2B27),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Validate integrity constraint requirements and repairs for $title.',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E2B27),
                    side: const BorderSide(color: Color(0xFF1E2B27)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await controller.runDryRun(title);
                    if (!context.mounted) return;
                    _showDryRunDialog(context, controller, title);
                  },
                  child: const Text('Dry Run'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2B27),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmExecution(context, controller, title),
                  child: const Text('Execute'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDryRunDialog(
    BuildContext context,
    MaintenanceController controller,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Dry Run Report: $title'),
          content: Obx(() {
            return Text(
              controller.rxDryRunReport.value.isNotEmpty
                  ? controller.rxDryRunReport.value
                  : 'Generating dry run logs...',
              style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmExecution(
    BuildContext context,
    MaintenanceController controller,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Migration Execution'),
          content: Text(
            'Are you sure you want to run live database repairs for "$title"? '
            'This action commits updates directly to Firestore in batches.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                controller.executeMigration(title);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
