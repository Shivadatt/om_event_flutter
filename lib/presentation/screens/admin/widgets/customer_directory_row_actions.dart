import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_details_dialog.dart';
import 'customer_edit_delete_dialogs.dart' hide CustomerEditDialog;
import 'edit_customer_dialog.dart';

/// Row action icon buttons (View, Edit, Delete) for Customer Directory.
class CustomerDirectoryRowActions extends StatelessWidget {
  final CustomerModel customer;
  final AdminController controller;
  final Color iconColor;
  final double iconSize;

  const CustomerDirectoryRowActions({
    super.key,
    required this.customer,
    required this.controller,
    required this.iconColor,
    this.iconSize = 17,
  });

  Widget _buildBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBtn(
          icon: Icons.visibility_outlined,
          color: iconColor,
          tooltip: 'View Details',
          onTap: () => Get.dialog(
            CustomerDetailsDialog(customer: customer, controller: controller),
          ),
        ),
        const SizedBox(width: 4),
        _buildBtn(
          icon: Icons.edit_outlined,
          color: iconColor,
          tooltip: 'Edit Client',
          onTap: () => Get.dialog(
            CustomerEditDialog(customer: customer, controller: controller),
          ),
        ),
        const SizedBox(width: 4),
        _buildBtn(
          icon: Icons.delete_outline_rounded,
          color: AppColors.error,
          tooltip: 'Delete Client',
          onTap: () => Get.dialog(
            CustomerDeleteDialog(customer: customer, controller: controller),
          ),
        ),
      ],
    );
  }
}
