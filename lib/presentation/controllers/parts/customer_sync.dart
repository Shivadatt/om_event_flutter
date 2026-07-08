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
      List<QueryDocumentSnapshot<Map<String, dynamic>>> matchedQuoteDocs = [];

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

        final quotesSnapshot = await db
            .collection(AppCollections.quotations)
            .where('customer_phone', whereIn: phoneVariations)
            .get();
        matchedQuoteDocs = quotesSnapshot.docs;
      } else if (profile.fullName.isNotEmpty) {
        // Fallback to name matching if phone is completely unavailable
        final quotesSnapshot = await db
            .collection(AppCollections.quotations)
            .where('customer_name', isEqualTo: profile.fullName)
            .get();
        matchedQuoteDocs = quotesSnapshot.docs;

        // If we matched a quote by name, extract its phone number and update user profile!
        if (matchedQuoteDocs.isNotEmpty) {
          final firstQuoteData = matchedQuoteDocs.first.data();
          final phoneFromQuote = firstQuoteData['customer_phone'] ?? firstQuoteData['customerPhone'] ?? '';
          if (phoneFromQuote.isNotEmpty) {
            syncPhone = phoneFromQuote;
            try {
              await db.collection(AppCollections.customerProfiles).doc(profile.id).update({
                'phone': syncPhone,
              });
              _authController.checkAuthStatus();
            } catch (_) {}
          }
        }
      }

      // 1. Sync Quotations
      for (var doc in matchedQuoteDocs) {
        final quoteData = doc.data();
        final quoteId = doc.id;
        final publicId = quoteData['public_id'] ?? quoteData['publicId'] ?? '';
        
        final subtotal = (quoteData['subtotal'] as num?)?.toDouble() ?? 0.0;
        final discount = (quoteData['discount'] as num?)?.toDouble() ?? 0.0;
        final amount = AppConstants.enableClientFeeWaiver 
            ? (subtotal - discount)
            : ((quoteData['grand_total'] ?? quoteData['grandTotal'] as num?)?.toDouble() ?? 0.0);

        final status = quoteData['status'] ?? 'pending';
        final dateStr = quoteData['event_date'] ?? quoteData['eventDate'] ?? DateTime.now().toIso8601String();
        final pdfUrl = quoteData['pdf_url'] ?? quoteData['pdfUrl'] ?? '';
        final notes = quoteData['notes'] ?? '';

        final rawItems = quoteData['items'] as List? ?? [];
        final mappedItems = rawItems.map((item) {
          final itemMap = Map<String, dynamic>.from(item);
          return {
            'experienceId': itemMap['decoration_item_slug'] ?? itemMap['experienceId'] ?? '',
            'name': itemMap['name'] ?? '',
            'quantity': itemMap['quantity'] ?? 1,
            'unitPrice': (itemMap['unit_price'] ?? itemMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
            'color': itemMap['color'] ?? '',
            'theme': itemMap['theme'] ?? '',
            'notes': itemMap['notes'] ?? '',
          };
        }).toList();

        final customerQuoteRef = db.collection(AppCollections.customerQuotes).doc(quoteId);
        await customerQuoteRef.set({
          'customerId': profile.id,
          'quotationNumber': publicId,
          'date': dateStr,
          'amount': amount,
          'status': status,
          'expiryDate': DateTime.tryParse(dateStr)?.add(const Duration(days: 7)).toIso8601String() ?? DateTime.now().toIso8601String(),
          'pdfUrl': pdfUrl,
          'notes': notes,
          'versionHistory': [],
          'items': mappedItems,
        });
      }

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

      // 3. Sync Bookings
      final allQuoteIds = matchedQuoteDocs.map((doc) => doc.id).toList();
      if (allQuoteIds.isNotEmpty) {
        final List<List<String>> chunks = [];
        for (var i = 0; i < allQuoteIds.length; i += 10) {
          chunks.add(allQuoteIds.sublist(i, i + 10 > allQuoteIds.length ? allQuoteIds.length : i + 10));
        }

        for (var chunk in chunks) {
          final bookingsSnapshot = await db
              .collection(AppCollections.bookings)
              .where('quotation_id', whereIn: chunk)
              .get();

          for (var doc in bookingsSnapshot.docs) {
            final bookingData = doc.data();
            final bookingId = doc.id;
            final bookingNumber = bookingData['booking_number'] ?? bookingData['bookingNumber'] ?? '';
            final status = bookingData['status'] ?? 'pending';
            final advanceAmount = (bookingData['advance_amount'] ?? bookingData['advanceAmount'] as num?)?.toDouble() ?? 0.0;
            final qId = bookingData['quotation_id'] ?? bookingData['quotationId'] ?? '';

            final matchedQuoteDoc = matchedQuoteDocs.firstWhere((q) => q.id == qId);
            final matchedQuoteData = matchedQuoteDoc.data();
            final location = matchedQuoteData['location'] ?? '';
            final grandTotal = (matchedQuoteData['grand_total'] ?? matchedQuoteData['grandTotal'] as num?)?.toDouble() ?? 0.0;
            final dateStr = matchedQuoteData['event_date'] ?? matchedQuoteData['eventDate'] ?? DateTime.now().toIso8601String();

            final customerBookingRef = db.collection(AppCollections.customerBookings).doc(bookingId);
            final customerBookingDoc = await customerBookingRef.get();
            if (!customerBookingDoc.exists) {
              await customerBookingRef.set({
                'customerId': profile.id,
                'bookingNumber': bookingNumber,
                'eventName': 'Event Celebration',
                'package': 'Custom Decoration',
                'branch': profile.branch.isNotEmpty ? profile.branch : 'Ahmedabad',
                'decorationType': 'Theme Decor',
                'date': dateStr,
                'venue': location,
                'amount': grandTotal,
                'advancePaid': advanceAmount,
                'remainingAmount': grandTotal - advanceAmount,
                'assignedBranch': profile.branch.isNotEmpty ? profile.branch : 'Ahmedabad',
                'assignedContact': 'Customer Relations',
                'status': status,
              });
            }
          }
        }
      }
    } catch (e) {
      // Fail silently
    }
  }
}
