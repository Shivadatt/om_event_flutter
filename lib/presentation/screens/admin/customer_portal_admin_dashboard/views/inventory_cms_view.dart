import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for decoration materials, stock tracking, and supplier details.
class InventoryCmsView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const InventoryCmsView({
    super.key,
    required this.portalController,
  });

  @override
  State<InventoryCmsView> createState() => _InventoryCmsViewState();
}

class _InventoryCmsViewState extends State<InventoryCmsView> {
  final nameCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final supplierCtrl = TextEditingController();

  final rxItems = <_MockInventory>[
    _MockInventory('I-01', 'Marigold Flowers (Fresh)', 150, 20, 'Kadi Agro Farms'),
    _MockInventory('I-02', 'LED Ambient Fairy Lights', 12, 15, 'Electra Wholesale'),
    _MockInventory('I-03', 'Wooden Stage Pillars', 4, 6, 'Om Timber Crafts'),
  ].obs;

  @override
  void dispose() {
    nameCtrl.dispose();
    stockCtrl.dispose();
    supplierCtrl.dispose();
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
              Text("Decoration Inventory & Stock Ledger", style: AppTheme.serifHeader(fontSize: 22)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add Material"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                onPressed: _showAddMaterialDialog,
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: rxItems.length,
                itemBuilder: (context, index) {
                  final item = rxItems[index];
                  final isLowStock = item.stock <= item.lowThreshold;

                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                      subtitle: Text("Stock: ${item.stock} units | Threshold: ${item.lowThreshold} units\nSupplier: ${item.supplier}"),
                      isThreeLine: true,
                      trailing: isLowStock
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.2), border: Border.all(color: Colors.redAccent)),
                              child: const Text("LOW STOCK", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          : Text("${item.stock} OK", style: const TextStyle(color: Colors.green, fontSize: 13)),
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

  void _showAddMaterialDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: const Text("Add Decoration Material", style: TextStyle(color: Color(0xFFC9A77E))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Material Name"),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: stockCtrl,
              decoration: const InputDecoration(labelText: "Starting Stock (Qty)"),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: supplierCtrl,
              decoration: const InputDecoration(labelText: "Supplier Name"),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              final stock = int.tryParse(stockCtrl.text) ?? 0;
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  rxItems.add(_MockInventory('I-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', nameCtrl.text, stock, 10, supplierCtrl.text));
                });
                nameCtrl.clear();
                stockCtrl.clear();
                supplierCtrl.clear();
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

class _MockInventory {
  final String id;
  final String name;
  final int stock;
  final int lowThreshold;
  final String supplier;
  _MockInventory(this.id, this.name, this.stock, this.lowThreshold, this.supplier);
}
