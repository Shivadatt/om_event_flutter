part of '../settings_notifications_tab.dart';

extension _NotifLifecycleExtension on _SettingsNotificationsTabState {
  Widget _buildTemplateVersionLifecycle() {
    return _buildCard(
      title: "TEMPLATE VERSION LIFECYCLE",
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACTIVE VERSION",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.black26,
                    child: Text(
                      activeTemplateVersion,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DRAFT VERSION",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.black26,
                    child: Text(
                      draftTemplateVersion,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                updateState(() {
                  activeTemplateVersion = 'v1.1.0';
                  draftTemplateVersion = 'v1.2.0-draft';
                });
                Get.snackbar(
                  "Template Published",
                  "Draft v1.1.0-draft rolled out to active templates.",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A77E),
                foregroundColor: Colors.black,
              ),
              child: const Text("Publish Draft to Active"),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                updateState(() {
                  activeTemplateVersion = 'v1.0.0';
                  draftTemplateVersion = 'v1.1.0-draft';
                });
                Get.snackbar(
                  "Rollback Success",
                  "Reverted active templates back to v1.0.0.",
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC9A77E)),
                foregroundColor: const Color(0xFFC9A77E),
              ),
              child: const Text("Rollback to Previous"),
            ),
          ],
        ),
      ],
    );
  }
}
