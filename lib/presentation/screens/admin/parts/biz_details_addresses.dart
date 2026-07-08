part of '../business_details_screen.dart';

extension BusinessDetailsAddresses on BusinessDetailsScreen {
  Widget _buildAddressesTab(BuildContext context, BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("UNLIMITED ADDRESSES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E), size: 28),
              onPressed: () => _showAddressDialog(context, controller, null),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.addresses.isEmpty) {
            return Text("No addresses configured.", style: AppTheme.sansBody(fontSize: 14, color: Colors.grey));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final a = controller.addresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D1A),
                  border: Border.all(color: const Color(0xFF254235)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(a.addressTitle, style: AppTheme.sansBody(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.street}, ${a.city}, ${a.state} - ${a.pincode}", style: AppTheme.sansBody(fontSize: 12, color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddressDialog(context, controller, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.addresses.removeAt(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showAddressDialog(BuildContext context, BusinessDetailsController controller, int? editIndex) {
    final isEditing = editIndex != null;
    final a = isEditing ? controller.addresses[editIndex] : null;

    final titleCtrl = TextEditingController(text: a?.addressTitle ?? "");
    final streetCtrl = TextEditingController(text: a?.street ?? "");
    final areaCtrl = TextEditingController(text: a?.area ?? "");
    final cityCtrl = TextEditingController(text: a?.city ?? "");
    final distCtrl = TextEditingController(text: a?.district ?? "");
    final stateCtrl = TextEditingController(text: a?.state ?? "");
    final countryCtrl = TextEditingController(text: a?.country ?? "India");
    final pinCtrl = TextEditingController(text: a?.pincode ?? "");
    final landmarkCtrl = TextEditingController(text: a?.landmark ?? "");
    final mapCtrl = TextEditingController(text: a?.googleMapsLink ?? "");
    final latCtrl = TextEditingController(text: a?.latitude ?? "");
    final lngCtrl = TextEditingController(text: a?.longitude ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1915),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC9A77E)),
          ),
          title: Text(
            isEditing ? "Edit Address" : "Add Address",
            style: GoogleFonts.italiana(color: const Color(0xFFC9A77E)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField("Address Title * (e.g. Main Office, Warehouse)", titleCtrl),
                _dialogField("Street Address", streetCtrl),
                _dialogField("Area / Locality", areaCtrl),
                Row(
                  children: [
                    Expanded(child: _dialogField("City *", cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("District", distCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _dialogField("State *", stateCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("Pincode *", pinCtrl)),
                  ],
                ),
                _dialogField("Country", countryCtrl),
                _dialogField("Landmark", landmarkCtrl),
                _dialogField("Google Maps Link", mapCtrl),
                Row(
                  children: [
                    Expanded(child: _dialogField("Latitude", latCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("Longitude", lngCtrl)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || cityCtrl.text.isEmpty || stateCtrl.text.isEmpty || pinCtrl.text.isEmpty) {
                  Get.snackbar(
                    "Validation Error",
                    "Title, City, State, and Pincode are required",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                final newAddr = AddressEntity(
                  id: a?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  addressTitle: titleCtrl.text.trim(),
                  street: streetCtrl.text.trim(),
                  area: areaCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  district: distCtrl.text.trim(),
                  state: stateCtrl.text.trim(),
                  country: countryCtrl.text.trim(),
                  pincode: pinCtrl.text.trim(),
                  landmark: landmarkCtrl.text.trim(),
                  googleMapsLink: mapCtrl.text.trim(),
                  latitude: latCtrl.text.trim(),
                  longitude: lngCtrl.text.trim(),
                );

                if (isEditing) {
                  controller.addresses[editIndex] = newAddr;
                } else {
                  controller.addresses.add(newAddr);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        );
      },
    );
  }
}
