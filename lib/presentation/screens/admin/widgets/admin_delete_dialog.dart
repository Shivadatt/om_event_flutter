import 'package:flutter/material.dart';
import 'admin_dialog.dart';

/// Reusable Admin record confirmation delete overlay dialog.
class AdminDeleteDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onDelete;

  const AdminDeleteDialog({
    super.key,
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDialog(
      title: "Confirm Delete",
      content: Text(
        "Are you sure you want to permanently delete \"$itemName\"?",
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          child: const Text(
            "DELETE",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
