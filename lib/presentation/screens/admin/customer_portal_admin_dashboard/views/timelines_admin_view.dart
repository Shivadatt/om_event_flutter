import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for updating booking progress timeline checkpoints.
class TimelinesAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const TimelinesAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<TimelinesAdminView> createState() => _TimelinesAdminViewState();
}

class _TimelinesAdminViewState extends State<TimelinesAdminView> {
  final noteCtrl = TextEditingController();
  String selectedStatus = 'Decoration Started';

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF12271F), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add Timeline Checkpoint", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: const Color(0xFF12271F),
                  items: const [
                    DropdownMenuItem(value: 'Decoration Started', child: Text("Decoration Started", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'Decoration Completed', child: Text("Decoration Completed", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'Review Pending', child: Text("Review Pending", style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedStatus = val);
                    }
                  },
                ),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: "Checkpoint Notes"),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
                  onPressed: () {
                    if (noteCtrl.text.isNotEmpty) {
                      widget.portalController.adminAddTimelineCheckpoint('MOCK_BOOKING_ID', selectedStatus, noteCtrl.text);
                      noteCtrl.clear();
                    }
                  },
                  child: const Text("Publish Checkpoint", style: TextStyle(color: Color(0xFF091210))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: widget.portalController.rxAllTimelines.length,
                itemBuilder: (context, index) {
                  final time = widget.portalController.rxAllTimelines[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(time.status, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                      subtitle: Text("${time.notes} | ${time.updatedTime.toLocal()}"),
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
}
