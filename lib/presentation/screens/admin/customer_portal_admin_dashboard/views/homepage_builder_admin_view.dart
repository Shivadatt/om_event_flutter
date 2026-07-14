import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Admin sub-view for building homepage section toggles and orders.
class HomepageBuilderAdminView extends StatelessWidget {
  final RxMap<String, bool> enabledSections;

  const HomepageBuilderAdminView({
    super.key,
    required this.enabledSections,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Homepage CMS Layout Section Builder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
          const SizedBox(height: 8),
          const Text("Configure active sections and priorities for the client-facing landing page.", style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView(
                children: enabledSections.keys.map((section) {
                  final isActive = enabledSections[section]!;
                  return SwitchListTile(
                    activeThumbColor: const Color(0xFFC9A77E),
                    title: Text(section, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(isActive ? "Visible on landing page" : "Hidden from landing page"),
                    value: isActive,
                    onChanged: (val) {
                      enabledSections[section] = val;
                      Get.snackbar("CMS Update", "$section state changed to ${val ? 'Enabled' : 'Disabled'}");
                    },
                  );
                }).toList(),
              );
            }),
          )
        ],
      ),
    );
  }
}
