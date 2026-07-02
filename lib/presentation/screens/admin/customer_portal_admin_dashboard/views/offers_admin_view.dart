import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for creating and editing banner offers/promotions.
class OffersAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const OffersAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<OffersAdminView> createState() => _OffersAdminViewState();
}

class _OffersAdminViewState extends State<OffersAdminView> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
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
                const Text("Create Offer & Promo Banner", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Promo Title"),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Promo Description"),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty && widget.portalController.rxAllOffers.isNotEmpty) {
                      final offer = widget.portalController.rxAllOffers.first;
                      widget.portalController.adminSaveOffer(offer);
                    }
                  },
                  child: const Text("Save Offer", style: TextStyle(color: Color(0xFF091210))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: widget.portalController.rxAllOffers.length,
                itemBuilder: (context, index) {
                  final offer = widget.portalController.rxAllOffers[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    child: ListTile(
                      title: Text(offer.title),
                      subtitle: Text(offer.description),
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
