import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for managing event coordinators.
class CoordinatorsAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const CoordinatorsAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<CoordinatorsAdminView> createState() => _CoordinatorsAdminViewState();
}

class _CoordinatorsAdminViewState extends State<CoordinatorsAdminView> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final rxCoordinators = <_MockCoordinator>[
    _MockCoordinator('C-01', 'Ankit Patel', '+91 99887 76655', 'Active'),
    _MockCoordinator('C-02', 'Priya Shah', '+91 99001 12233', 'Active'),
  ].obs;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Coordinator CMS Directory", style: AppTheme.serifHeader(fontSize: 22)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Register Coordinator"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                onPressed: _showRegisterDialog,
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: rxCoordinators.length,
                itemBuilder: (context, index) {
                  final coord = rxCoordinators[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFC9A77E),
                        child: Icon(Icons.person, color: Color(0xFF091210)),
                      ),
                      title: Text(coord.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                      subtitle: Text("Phone: ${coord.phone} | Status: ${coord.status}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                            onPressed: () {},
                          ),
                          Switch(
                            value: coord.status == 'Active',
                            activeThumbColor: const Color(0xFFC9A77E),
                            onChanged: (val) {
                              setState(() {
                                coord.status = val ? 'Active' : 'Inactive';
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  void _showRegisterDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: const Text("Register Coordinator", style: TextStyle(color: Color(0xFFC9A77E))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Contact Phone"),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  rxCoordinators.add(_MockCoordinator('C-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', nameCtrl.text, phoneCtrl.text, 'Active'));
                });
                nameCtrl.clear();
                phoneCtrl.clear();
                Get.back();
              }
            },
            child: const Text("Register", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }
}

class _MockCoordinator {
  final String id;
  final String name;
  final String phone;
  String status;
  _MockCoordinator(this.id, this.name, this.phone, this.status);
}
