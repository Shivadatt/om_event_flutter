import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/utils/formatters.dart';

class ManageCustomersScreen extends GetView<AdminController> {
  const ManageCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController();
    final rxSearchQuery = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CUSTOMER DIRECTORY",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search customer name, phone, email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchCtrl.clear();
                    rxSearchQuery.value = '';
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                rxSearchQuery.value = val.toLowerCase().trim();
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCustomers.value) {
                return const Center(child: CircularProgressIndicator());
              }

              var list = controller.rxCustomers.toList();
              final query = rxSearchQuery.value;
              if (query.isNotEmpty) {
                list =
                    list
                        .where(
                          (c) =>
                              c.name.toLowerCase().contains(query) ||
                              c.phone.contains(query) ||
                              c.email.toLowerCase().contains(query),
                        )
                        .toList();
              }

              if (list.isEmpty) {
                return const Center(
                  child: Text("No customers matching search criteria."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final customer = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: ListTile(
                      title: Text(
                        customer.name,
                        style: AppTheme.serifHeader(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${customer.phone} | ${customer.email}",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color:
                              isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed:
                                () =>
                                    _showEditCustomerDialog(context, customer),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _confirmDelete(customer.phone),
                          ),
                        ],
                      ),
                      onTap:
                          () => _showCustomerDetailsDrawer(context, customer),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String phone) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Customer"),
        content: Text(
          "Are you sure you want to delete customer '$phone'? This will remove their record from the directory.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteCustomer(phone);
            },
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final emailCtrl = TextEditingController(text: customer.email);
    final addrCtrl = TextEditingController(text: customer.address);
    final cityCtrl = TextEditingController(text: customer.city);
    final locCtrl = TextEditingController(text: customer.mapLocation);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Customer Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: "Map Location"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              final updated = CustomerModel(
                id: customer.id,
                name: nameCtrl.text.trim(),
                phone: customer.phone,
                email: emailCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                mapLocation: locCtrl.text.trim(),
                createdAt: customer.createdAt,
                updatedAt: DateTime.now(),
              );
              Get.back();
              controller.saveCustomer(updated);
            },
          ),
        ],
      ),
    );
  }

  void _showCustomerDetailsDrawer(
    BuildContext context,
    CustomerModel customer,
  ) {
    // Filter quotes and leads in memory
    final quotes =
        controller.rxQuotes
            .where((q) => q.customerPhone == customer.phone)
            .toList();
    final leads =
        controller.rxLeads.where((l) => l.phone == customer.phone).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141D1A) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customer.name,
                    style: AppTheme.serifHeader(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Phone: ${customer.phone}",
                style: AppTheme.sansBody(fontSize: 13),
              ),
              Text(
                "Email: ${customer.email}",
                style: AppTheme.sansBody(fontSize: 13),
              ),
              Text(
                "Location: ${customer.city} | Address: ${customer.address}",
                style: AppTheme.sansBody(fontSize: 13),
              ),
              if (customer.mapLocation.isNotEmpty)
                Text(
                  "Map Location: ${customer.mapLocation}",
                  style: AppTheme.sansBody(fontSize: 13, color: Colors.blue),
                ),
              const Divider(height: 24),

              // Previous Quotations
              Text(
                "PREVIOUS QUOTATIONS (${quotes.length})",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (quotes.isEmpty)
                Text(
                  "No quotes found.",
                  style: AppTheme.sansBody(fontSize: 12, color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final q = quotes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Quote ID: ${q.publicId}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Grand Total: ${AppFormatters.formatCurrency(q.grandTotal)} | Date: ${q.createdAt.toString().split(' ').first}",
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        q.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              q.status == 'approved'
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              const Divider(height: 24),

              // Leads
              Text(
                "INQUIRY LEADS (${leads.length})",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (leads.isEmpty)
                Text(
                  "No inquiries found.",
                  style: AppTheme.sansBody(fontSize: 12, color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final l = leads[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l.requestType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Event Date: ${l.eventDate.toString().split(' ').first} | Status: ${l.status}",
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
