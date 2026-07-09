part of '../customer_dashboard_controller.dart';

extension CustomerSyncExtension on CustomerDashboardController {
  Future<void> syncMasterData(CustomerProfile profile) async {
    final db = FirebaseFirestore.instance;
    String syncPhone = profile.phone;

    // If profile phone is empty, try to resolve it from the master customers collection or leads collection
    if (syncPhone.isEmpty) {
      try {
        // A. Search in master customers by email
        final custSnap = await db
            .collection(AppCollections.customers)
            .where('email', isEqualTo: profile.email)
            .get();
        if (custSnap.docs.isNotEmpty) {
          syncPhone = custSnap.docs.first.id;
        }

        // B. If still empty, search in master leads by email
        if (syncPhone.isEmpty) {
          final leadSnap = await db
              .collection(AppCollections.leads)
              .where('email', isEqualTo: profile.email)
              .get();
          if (leadSnap.docs.isNotEmpty) {
            syncPhone = leadSnap.docs.first.data()['phone'] ?? '';
          }
        }

        // C. If we found a phone number, update the profile automatically so it's persisted!
        if (syncPhone.isNotEmpty) {
          await db.collection(AppCollections.customerProfiles).doc(profile.id).update({
            'phone': syncPhone,
          });
          // Update local state
          _authController.checkAuthStatus();
        }
      } catch (e) {
        // Silent error
      }
    }

    try {
      // 1. Quotation linking logic is fully migrated to startup database migration service.
      // Phone-based matching and name-matching healing are removed.

      // 2. Sync Leads / Inquiries
      if (syncPhone.isNotEmpty) {
        final normalizedPhone = syncPhone.replaceAll(RegExp(r'\D'), '');
        final tenDigitPhone = normalizedPhone.length >= 10 
            ? normalizedPhone.substring(normalizedPhone.length - 10) 
            : normalizedPhone;

        final phoneVariations = {
          syncPhone,
          normalizedPhone,
          tenDigitPhone,
          if (tenDigitPhone.length == 10) "+91$tenDigitPhone",
          if (tenDigitPhone.length == 10) "91$tenDigitPhone",
          if (tenDigitPhone.length == 10) "0$tenDigitPhone",
        }.toList();

        final leadsSnapshot = await db
            .collection(AppCollections.leads)
            .where('phone', whereIn: phoneVariations)
            .get();

        for (var doc in leadsSnapshot.docs) {
          final leadData = doc.data();
          final leadId = doc.id;
          final service = leadData['requirements'] ?? 'Event Inquiry';
          final budget = (leadData['budget'] as num?)?.toDouble() ?? 0.0;
          final eventDateStr = leadData['event_date'] ?? leadData['eventDate'] ?? DateTime.now().toIso8601String();
          final status = leadData['status'] ?? 'Pending';

          final customerLeadRef = db.collection(AppCollections.customerLeads).doc(leadId);
          final customerLeadDoc = await customerLeadRef.get();
          if (!customerLeadDoc.exists) {
            await customerLeadRef.set({
              'customerId': profile.id,
              'leadNumber': 'L-$leadId',
              'date': DateTime.now().toIso8601String(),
              'service': service,
              'branch': profile.branch.isNotEmpty ? profile.branch : 'Ahmedabad',
              'budget': budget,
              'eventDate': eventDateStr,
              'status': status,
              'adminNotes': '',
            });
          }
        }
      } else if (profile.fullName.isNotEmpty) {
        // Fallback matching leads by name if phone is not set
        final leadsSnapshot = await db
            .collection(AppCollections.leads)
            .where('name', isEqualTo: profile.fullName)
            .get();

        for (var doc in leadsSnapshot.docs) {
          final leadData = doc.data();
          final leadId = doc.id;
          final service = leadData['requirements'] ?? 'Event Inquiry';
          final budget = (leadData['budget'] as num?)?.toDouble() ?? 0.0;
          final eventDateStr = leadData['event_date'] ?? leadData['eventDate'] ?? DateTime.now().toIso8601String();
          final status = leadData['status'] ?? 'Pending';

          final customerLeadRef = db.collection(AppCollections.customerLeads).doc(leadId);
          final customerLeadDoc = await customerLeadRef.get();
          if (!customerLeadDoc.exists) {
            await customerLeadRef.set({
              'customerId': profile.id,
              'leadNumber': 'L-$leadId',
              'date': DateTime.now().toIso8601String(),
              'service': service,
              'branch': profile.branch.isNotEmpty ? profile.branch : 'Ahmedabad',
              'budget': budget,
              'eventDate': eventDateStr,
              'status': status,
              'adminNotes': '',
            });
          }
        }
      }

    } catch (e) {
      // Fail silently
    }
  }
}
