import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Wishlist items management view for customers.
class WishlistView extends StatelessWidget {
  final CustomerDashboardController controller;

  const WishlistView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Decoration Wishlist", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.rxWishlist.isEmpty) {
                return const Center(child: Text("No items saved. Add items from the Home portal."));
              }
              return ListView.builder(
                itemCount: controller.rxWishlist.length,
                itemBuilder: (context, index) {
                  final wish = controller.rxWishlist[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text("Decoration ID: ${wish.experienceId}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                      subtitle: Text("Added: ${wish.addedAt.toLocal().toString().split(' ').first}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => controller.removeWishlist(wish.id),
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
}
