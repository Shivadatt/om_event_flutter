part of '../catalog_controller.dart';

extension CatalogLeadExtension on CatalogController {
  Future<bool> handleRequestCallback({
    required String name,
    required String phone,
    required String dateStr,
    required String budgetStr,
    required String requirements,
  }) async {
    if (!AppValidators.isValidName(name)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid name (at least 2 letters).",
      );
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
      );
      return false;
    }

    try {
      isSubmittingLead.value = true;
      final cleanedPhone = AppValidators.cleanPhone(phone);
      final budget = double.tryParse(budgetStr) ?? 0.0;
      final eventDate = DateTime.tryParse(dateStr);

      final lead = Lead(
        id: '',
        name: name.trim(),
        phone: cleanedPhone,
        email: '',
        requestType: 'callback',
        eventDate: eventDate,
        budget: budget > 0 ? budget : null,
        requirements: requirements.trim(),
        status: 'new',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await submitLead(lead);

      // If customer is logged in, link lead to customer portal
      final authCtrl = Get.find<CustomerAuthController>();
      final customerId = authCtrl.rxCustomerProfile.value?.id ?? '';
      if (customerId.isNotEmpty) {
        final leadId = DateTime.now().millisecondsSinceEpoch.toString();
        final customerLeadRef = FirebaseFirestore.instance.collection(AppCollections.customerLeads).doc(leadId);
        await customerLeadRef.set({
          'customerId': customerId,
          'leadNumber': 'L-${DateTime.now().millisecondsSinceEpoch}',
          'date': DateTime.now().toIso8601String(),
          'service': requirements.trim().isNotEmpty ? requirements.trim() : 'Event Inquiry',
          'branch': authCtrl.rxCustomerProfile.value?.branch ?? 'Ahmedabad',
          'budget': budget,
          'eventDate': eventDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'status': 'Pending',
          'adminNotes': '',
        });
      }

      Get.snackbar(
        "Inquiry Received",
        "Thank you! Our event manager will call you shortly.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on Failure catch (e) {
      Get.snackbar("Inquiry Failed", e.message);
      return false;
    } catch (e) {
      Get.snackbar("Inquiry Failed", e.toString());
      return false;
    } finally {
      isSubmittingLead.value = false;
    }
  }
}
