import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/quotation_pdf_generator.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/quotation_version.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../datasources/supabase_storage_source.dart';
import '../models/quotation_model.dart';
import '../models/quotation_version_model.dart';
import '../../core/services/supabase_edge_functions.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  final FirestoreRemoteSource firestoreSource;
  final SupabaseStorageSource? supabaseSource;

  QuotationRepositoryImpl({required this.firestoreSource, this.supabaseSource});

  @override
  Future<Quotation> createQuotation(Quotation quotation) async {
    try {
      if (quotation.customerId.trim().isEmpty) {
        throw const ServerFailure("Customer UID not found. Cannot create quotation.");
      }
      if (quotation.customerName.trim().isEmpty) {
        throw const ServerFailure("Customer name is required.");
      }
      if (quotation.customerPhone.trim().isEmpty) {
        throw const ServerFailure("Customer phone is required.");
      }
      if (quotation.items.isEmpty) {
        throw const ServerFailure("At least one quotation item is required.");
      }
      if (quotation.grandTotal <= 0) {
        throw const ServerFailure("Quotation grand total must be positive.");
      }

      final model = QuotationModel(
        id: quotation.id,
        customerId: quotation.customerId,
        publicId: quotation.publicId,
        customerPhone: quotation.customerPhone,
        customerName: quotation.customerName,
        eventDate: quotation.eventDate,
        eventTime: quotation.eventTime,
        location: quotation.location,
        notes: quotation.notes,
        subtotal: quotation.subtotal,
        discount: quotation.discount,
        deliveryCharge: quotation.deliveryCharge,
        travelCharge: quotation.travelCharge,
        gstPercent: quotation.gstPercent,
        gstAmount: quotation.gstAmount,
        grandTotal: quotation.grandTotal,
        pdfUrl: quotation.pdfUrl,
        status: quotation.status,
        items:
            quotation.items
                .map(
                  (e) => QuotationItemModel(
                    experienceId: e.experienceId,
                    name: e.name,
                    quantity: e.quantity,
                    unitPrice: e.unitPrice,
                    color: e.color,
                    theme: e.theme,
                    notes: e.notes,
                  ),
                )
                .toList(),
        createdAt: quotation.createdAt,
        updatedAt: quotation.updatedAt,
      );

      await firestoreSource.submitQuotation(model.toJson(), quotation.id);

      SupabaseEdgeFunctions.to.invoke('quotation-event', {
        'eventType': 'created',
        'quoteId': quotation.id.isEmpty ? model.id : quotation.id,
      });

      // Upsert customer record exactly like Python Django backend
      await firestoreSource.upsertCustomer(
        phone: quotation.customerPhone,
        name: quotation.customerName,
        email: '',
      );

      return model;
    } catch (e) {
      throw ServerFailure("Failed to create quotation: ${e.toString()}");
    }
  }

  @override
  Future<String> uploadQuotationPdf(String publicId, List<int> pdfBytes) async {
    try {
      if (supabaseSource == null) {
        throw const ServerFailure(
          "Supabase Storage integration is not configured.",
        );
      }
      final filePath = 'quotes/$publicId.pdf';
      return await supabaseSource!.uploadFile(
        filePath,
        pdfBytes,
        'application/pdf',
      );
    } catch (e) {
      throw ServerFailure(
        "Failed to upload quotation proposal PDF: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<Quotation>> getQuotations() async {
    try {
      final docs = await firestoreSource.fetchQuotations();
      return docs
          .map((doc) => QuotationModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure("Failed to fetch quotations list: ${e.toString()}");
    }
  }

  @override
  Future<Quotation> getQuotationByPublicId(String publicId) async {
    try {
      final doc = await firestoreSource.fetchQuotationByPublicId(publicId);
      final model = QuotationModel.fromJson(doc.data()!, doc.id);
      final versions = await _getVersionsForQuotation(
        doc.id,
        model.legacyVersionHistory,
        model.items,
      );
      return model.copyWith(versions: versions);
    } catch (e) {
      throw ServerFailure("Quotation not found: ${e.toString()}");
    }
  }

  @override
  Future<void> updateQuotationStatus(String id, String status) async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection(AppCollections.quotations).doc(id).get();
      if (!doc.exists) {
        throw ServerFailure("Quotation not found");
      }

      final data = doc.data()!;
      final currentStatusStr = data['status'] ?? 'draft';
      final currentStatus = QuotationStatus.fromString(currentStatusStr);
      final targetStatus = QuotationStatus.fromString(status);

      if (!QuotationStatusTransitions.isValid(currentStatus, targetStatus)) {
        throw ServerFailure("Invalid status transition from $currentStatusStr to $status");
      }

      final updateData = <String, dynamic>{
        'status': targetStatus.nameStr,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 1. Version snapshotting and field updates based on targetStatus
      if (targetStatus == QuotationStatus.viewed) {
        updateData['customerViewedAt'] = DateTime.now().toIso8601String();
      } else if (targetStatus == QuotationStatus.revisionRequested) {
        updateData['customerAction'] = 'revision_requested';
        updateData['customerActionAt'] = DateTime.now().toIso8601String();
      } else if (targetStatus == QuotationStatus.acceptedByClient) {
        updateData['customerAction'] = 'accepted';
        updateData['customerActionAt'] = DateTime.now().toIso8601String();
        updateData['isFinancialLocked'] = true;
      } else if (targetStatus == QuotationStatus.bookingConfirmed) {
        updateData['isFinancialLocked'] = true;
        updateData['isPermanentlyLocked'] = true;
      } else if (targetStatus == QuotationStatus.rejectedByClient) {
        updateData['customerAction'] = 'rejected';
        updateData['customerActionAt'] = DateTime.now().toIso8601String();
      } else if (targetStatus == QuotationStatus.published || targetStatus == QuotationStatus.republished) {
        if (currentStatus == QuotationStatus.draft) {
          updateData['status'] = QuotationStatus.published.nameStr;
          updateData['version'] = 1;
          updateData['publishedAt'] = DateTime.now().toIso8601String();
          updateData['lastPublishedAt'] = DateTime.now().toIso8601String();
          updateData['publishedBy'] = 'Admin';
        } else {
          // Creating a new version snapshot in quotation_versions collection
          final previousVersionNum = data['version'] ?? 1;
          final versionId = '${id}_$previousVersionNum';
          
          final rawItems = data['items'] as List? ?? [];
          final itemsList = rawItems
              .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          final versionModel = QuotationVersionModel(
            id: versionId,
            quotationId: id,
            versionNumber: previousVersionNum,
            items: itemsList,
            subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
            discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
            gstPercent: (data['gst_percent'] ?? data['gstPercent'] as num?)?.toDouble() ?? 18.0,
            gstAmount: (data['gst_amount'] ?? data['gstAmount'] as num?)?.toDouble() ?? 0.0,
            deliveryCharge: (data['delivery_charge'] ?? data['deliveryCharge'] ?? data['delivery'] as num?)?.toDouble() ?? 0.0,
            travelCharge: (data['travel_charge'] ?? data['travelCharge'] as num?)?.toDouble() ?? 0.0,
            grandTotal: (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ?? 0.0,
            adminMessage: data['adminMessage'] ?? data['admin_message'],
            publishedAt: DateTime.tryParse(data['updated_at'] ?? data['updatedAt'] ?? '') ?? DateTime.now(),
            publishedBy: data['publishedBy'] ?? 'Admin',
            pdfUrl: data['pdf_url'] ?? data['pdfUrl'] ?? '',
            revisionReason: data['revisionReason'] ?? data['revision_reason'] ?? 'Admin Revision',
          );
          
          await db.collection('quotation_versions').doc(versionId).set(versionModel.toJson());

          updateData['status'] = QuotationStatus.republished.nameStr;
          updateData['version'] = previousVersionNum + 1;
          updateData['lastPublishedAt'] = DateTime.now().toIso8601String();
          updateData['revisionReason'] = FieldValue.delete();
          updateData['revisionMessage'] = FieldValue.delete();
        }
      }

      // Build updated quotation object to pass to PDF generator
      final mergedData = Map<String, dynamic>.from(data)..addAll(updateData);
      
      // Clean up FieldValue.delete() values for local model parsing
      mergedData.forEach((key, value) {
        if (value is FieldValue) {
          mergedData[key] = null;
        }
      });

      final updatedQuotation = QuotationModel.fromJson(mergedData, id);

      // Regenerate the PDF bytes automatically if publishing/republishing
      if (targetStatus == QuotationStatus.published || targetStatus == QuotationStatus.republished) {
        if (supabaseSource != null) {
          try {
            final pdfBytes = await QuotationPdfGenerator.generate(updatedQuotation);
            final uploadedPdfUrl = await uploadQuotationPdf(updatedQuotation.publicId, pdfBytes);
            updateData['pdf_url'] = uploadedPdfUrl;
          } catch (_) {}
        }
      }

        // Update Firestore document
        await db.collection(AppCollections.quotations).doc(id).update(updateData);

        // Post system/revision messages to quotation discussion chat
        String chatMsg = '';
        String chatMsgType = 'system';
        String? chatSenderRole;
        String? chatSenderName;
        String? chatSenderId;

        switch (targetStatus) {
          case QuotationStatus.published:
          case QuotationStatus.republished:
            chatMsg = targetStatus == QuotationStatus.published
                ? 'Proposal Published by Admin.'
                : 'Revised proposal published by Admin.';
            chatSenderRole = 'admin';
            chatSenderName = 'Admin';
            chatSenderId = 'admin';
            break;
          case QuotationStatus.acceptedByClient:
            chatMsg = 'Proposal accepted by Customer.';
            chatSenderRole = 'client';
            chatSenderName = data['customerName'] ?? 'Customer';
            chatSenderId = data['customerId'];
            break;
          case QuotationStatus.rejectedByClient:
            chatMsg = 'Proposal declined by Customer.';
            chatSenderRole = 'client';
            chatSenderName = data['customerName'] ?? 'Customer';
            chatSenderId = data['customerId'];
            break;
          case QuotationStatus.revisionRequested:
            chatMsg = 'Revision Requested: "${data['revisionReason'] ?? data['revision_reason'] ?? 'No comments'}"';
            chatMsgType = 'revision';
            chatSenderRole = 'client';
            chatSenderName = data['customerName'] ?? 'Customer';
            chatSenderId = data['customerId'];
            break;
          case QuotationStatus.underRevision:
            chatMsg = 'Admin started revising the proposal layout and items.';
            chatSenderRole = 'admin';
            chatSenderName = 'Admin';
            chatSenderId = 'admin';
            break;
          case QuotationStatus.bookingConfirmed:
            chatMsg = 'Proposal successfully converted to active booking.';
            chatSenderRole = 'admin';
            chatSenderName = 'Admin';
            chatSenderId = 'admin';
            break;
          case QuotationStatus.expired:
            chatMsg = 'Proposal expired.';
            break;
          case QuotationStatus.cancelled:
            chatMsg = 'Proposal cancelled.';
            break;
          case QuotationStatus.archived:
            chatMsg = 'Proposal archived.';
            chatSenderRole = 'admin';
            chatSenderName = 'Admin';
            chatSenderId = 'admin';
            break;
          default:
            break;
        }

        if (chatMsg.isNotEmpty) {
          await _postSystemMessage(
            id,
            chatMsg,
            chatMsgType,
            senderId: chatSenderId,
            senderName: chatSenderName,
            senderRole: chatSenderRole,
          );
        }

      // 2. Activity Logging & Notifications
      final customerId = data['customerId'] ?? data['customer_id'] ?? '';
      final customerName = data['customer_name'] ?? data['customerName'] ?? 'Client';
      final publicId = data['public_id'] ?? data['publicId'] ?? id;

      if (customerId.isNotEmpty) {
        String logDetails = '';
        String notifyTitle = '';
        String notifyBody = '';
        String notifyType = 'info';

        switch (targetStatus) {
          case QuotationStatus.acceptedByClient:
            logDetails = 'Client Accepted Quotation $publicId.';
            notifyTitle = 'Quotation Accepted';
            notifyBody = 'Client $customerName has accepted proposal $publicId.';
            notifyType = 'action_required';
            break;
          case QuotationStatus.rejectedByClient:
            logDetails = 'Client Rejected Quotation $publicId.';
            notifyTitle = 'Quotation Rejected';
            notifyBody = 'Client $customerName rejected proposal $publicId.';
            notifyType = 'alert';
            break;
          case QuotationStatus.revisionRequested:
            logDetails = 'Client requested revision for quotation $publicId.';
            notifyTitle = 'Revision Requested';
            notifyBody = 'Client $customerName requested revision for proposal $publicId.';
            notifyType = 'action_required';
            break;
          case QuotationStatus.bookingConfirmed:
            logDetails = 'Admin Confirmed Booking for Quotation $publicId.';
            notifyTitle = 'Booking Confirmed!';
            notifyBody = 'Your quotation $publicId has been confirmed as a booking reservation.';
            notifyType = 'booking';
            break;
          case QuotationStatus.published:
            logDetails = 'Admin published quotation $publicId.';
            notifyTitle = 'New Proposal Draft Published';
            notifyBody = 'A new proposal version $publicId has been sent for your review.';
            notifyType = 'proposal';
            break;
          case QuotationStatus.republished:
            logDetails = 'Admin published revised quotation $publicId.';
            notifyTitle = 'Revised Proposal Published';
            notifyBody = 'Admin has published a revised version of proposal $publicId.';
            notifyType = 'proposal';
            break;
          case QuotationStatus.viewed:
            logDetails = 'Client viewed quotation $publicId.';
            notifyTitle = 'Proposal Viewed';
            notifyBody = 'Client $customerName viewed proposal $publicId.';
            notifyType = 'proposal_viewed';
            break;
          default:
            logDetails = 'Quotation status updated from $currentStatusStr to $status.';
            break;
        }

        if (logDetails.isNotEmpty) {
          // Log to customer activity timeline
          await db.collection(AppCollections.customerActivity).add({
            'customerId': customerId,
            'status': 'Quotation',
            'updatedAt': DateTime.now().toIso8601String(),
            'details': logDetails,
          });

          // Resolve action user and role for audit logs
          String auditUser = 'System';
          String auditRole = 'system';
          String auditAction = 'Quotation Status Update';

          switch (targetStatus) {
            case QuotationStatus.published:
            case QuotationStatus.republished:
              auditUser = 'Admin';
              auditRole = 'admin';
              auditAction = targetStatus == QuotationStatus.published ? 'Proposal Published' : 'Revision Published';
              break;
            case QuotationStatus.viewed:
              auditUser = customerName;
              auditRole = 'client';
              auditAction = 'Proposal Viewed';
              break;
            case QuotationStatus.revisionRequested:
              auditUser = customerName;
              auditRole = 'client';
              auditAction = 'Revision Requested';
              break;
            case QuotationStatus.acceptedByClient:
              auditUser = customerName;
              auditRole = 'client';
              auditAction = 'Client Accepted';
              break;
            case QuotationStatus.rejectedByClient:
              auditUser = customerName;
              auditRole = 'client';
              auditAction = 'Client Rejected';
              break;
            case QuotationStatus.bookingConfirmed:
              auditUser = 'Admin';
              auditRole = 'admin';
              auditAction = 'Booking Confirmed';
              break;
            default:
              break;
          }

          final quotationVer = data['version'] ?? 1;

          await _writeAuditLog(
            action: auditAction,
            user: auditUser,
            role: auditRole,
            version: quotationVer,
            quotationId: id,
            details: logDetails,
          );
        }

        if (notifyTitle.isNotEmpty) {
          final isToAdmin = targetStatus == QuotationStatus.acceptedByClient ||
              targetStatus == QuotationStatus.rejectedByClient ||
              targetStatus == QuotationStatus.revisionRequested ||
              targetStatus == QuotationStatus.viewed;

          await db.collection(AppCollections.customerNotifications).add({
            'customerId': isToAdmin ? 'admin' : customerId,
            'title': notifyTitle,
            'body': notifyBody,
            'type': notifyType,
            'isRead': false,
            'createdAt': DateTime.now().toIso8601String(),
            'branch': data['location'] ?? '',
            'quotationId': id,
          });
        }
      }
      SupabaseEdgeFunctions.to.invoke('quotation-event', {
        'eventType': 'updated',
        'quoteId': id,
      });
    } catch (e) {
      throw ServerFailure("Failed to update status: ${e.toString()}");
    }
  }

  @override
  Stream<List<Quotation>> streamAllQuotations() {
    return FirebaseFirestore.instance
        .collection(AppCollections.quotations)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final List<Quotation> quotesList = [];
          for (var doc in snap.docs) {
            final model = QuotationModel.fromJson(doc.data(), doc.id);
            final versions = await _getVersionsForQuotation(
              doc.id,
              model.legacyVersionHistory,
              model.items,
            );
            quotesList.add(model.copyWith(versions: versions));
          }
          return quotesList;
        });
  }

  @override
  Stream<List<Quotation>> streamCustomerQuotations(String customerId) {
    if (customerId.isEmpty) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection(AppCollections.quotations)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .asyncMap((snap) async {
          final List<Quotation> quotesList = [];
          for (var doc in snap.docs) {
            final model = QuotationModel.fromJson(doc.data(), doc.id);
            final versions = await _getVersionsForQuotation(
              doc.id,
              model.legacyVersionHistory,
              model.items,
            );
            quotesList.add(model.copyWith(versions: versions));
          }
          quotesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return quotesList;
        });
  }

  @override
  Future<void> saveQuotationDraft(Quotation quotation) async {
    try {
      final db = FirebaseFirestore.instance;
      final model = QuotationModel(
        id: quotation.id,
        publicId: quotation.publicId,
        customerPhone: quotation.customerPhone,
        customerName: quotation.customerName,
        eventDate: quotation.eventDate,
        eventTime: quotation.eventTime,
        location: quotation.location,
        notes: quotation.notes,
        subtotal: quotation.subtotal,
        discount: quotation.discount,
        deliveryCharge: quotation.deliveryCharge,
        travelCharge: quotation.travelCharge,
        gstPercent: quotation.gstPercent,
        gstAmount: quotation.gstAmount,
        grandTotal: quotation.grandTotal,
        pdfUrl: quotation.pdfUrl,
        status: quotation.status,
        items: quotation.items.map((e) => QuotationItemModel(
          experienceId: e.experienceId,
          name: e.name,
          quantity: e.quantity,
          unitPrice: e.unitPrice,
          color: e.color,
          theme: e.theme,
          notes: e.notes,
        )).toList(),
        createdAt: quotation.createdAt,
        updatedAt: DateTime.now(),
        customerId: quotation.customerId,
        versions: quotation.versions,
        version: quotation.version,
        publishedAt: quotation.publishedAt,
        publishedBy: quotation.publishedBy,
        revisionReason: quotation.revisionReason,
        revisionMessage: quotation.revisionMessage,
        adminMessage: quotation.adminMessage,
        customerAction: quotation.customerAction,
        customerActionAt: quotation.customerActionAt,
        customerViewedAt: quotation.customerViewedAt,
        lastPublishedAt: quotation.lastPublishedAt,
        internalNotes: quotation.internalNotes,
      );
      await db.collection('quotation_drafts').doc(quotation.id).set(model.toJson());
    } catch (e) {
      throw ServerFailure("Failed to save draft: ${e.toString()}");
    }
  }

  @override
  Future<Quotation?> getQuotationDraft(String id) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('quotation_drafts').doc(id).get();
      if (!doc.exists) return null;
      return QuotationModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerFailure("Failed to load draft: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteQuotationDraft(String id) async {
    try {
      await FirebaseFirestore.instance.collection('quotation_drafts').doc(id).delete();
    } catch (e) {
      throw ServerFailure("Failed to delete draft: ${e.toString()}");
    }
  }

  @override
  Future<void> publishQuotationRevision(Quotation quotation) async {
    try {
      final db = FirebaseFirestore.instance;
      
      final doc = await db.collection(AppCollections.quotations).doc(quotation.id).get();
      if (!doc.exists) {
        throw ServerFailure("Quotation not found");
      }

      final data = doc.data()!;
      final previousVersionNum = data['version'] ?? 1;
      final versionId = '${quotation.id}_$previousVersionNum';
      
      final rawItems = data['items'] as List? ?? [];
      final itemsList = rawItems
          .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final versionModel = QuotationVersionModel(
        id: versionId,
        quotationId: quotation.id,
        versionNumber: previousVersionNum,
        items: itemsList,
        subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
        discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
        gstPercent: (data['gst_percent'] ?? data['gstPercent'] as num?)?.toDouble() ?? 18.0,
        gstAmount: (data['gst_amount'] ?? data['gstAmount'] as num?)?.toDouble() ?? 0.0,
        deliveryCharge: (data['delivery_charge'] ?? data['deliveryCharge'] ?? data['delivery'] as num?)?.toDouble() ?? 0.0,
        travelCharge: (data['travel_charge'] ?? data['travelCharge'] as num?)?.toDouble() ?? 0.0,
        grandTotal: (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ?? 0.0,
        adminMessage: data['adminMessage'] ?? data['admin_message'],
        publishedAt: DateTime.tryParse(data['updated_at'] ?? data['updatedAt'] ?? '') ?? DateTime.now(),
        publishedBy: data['publishedBy'] ?? 'Admin',
        pdfUrl: data['pdf_url'] ?? data['pdfUrl'] ?? '',
        revisionReason: quotation.revisionReason ?? 'Admin Revision',
      );

      await db.collection('quotation_versions').doc(versionId).set(versionModel.toJson());

      final newVersion = previousVersionNum + 1;
      final newStatus = QuotationStatus.republished;

      var updatedQuotation = quotation.resetConsent().copyWith(
        version: newVersion,
        status: newStatus,
        updatedAt: DateTime.now(),
        lastPublishedAt: DateTime.now(),
        revisionReason: null,
        revisionMessage: null,
      );

      if (supabaseSource != null) {
        try {
          final pdfBytes = await QuotationPdfGenerator.generate(updatedQuotation);
          final uploadedPdfUrl = await uploadQuotationPdf(updatedQuotation.publicId, pdfBytes);
          updatedQuotation = updatedQuotation.copyWith(pdfUrl: uploadedPdfUrl);
        } catch (_) {}
      }

      final model = QuotationModel(
        id: updatedQuotation.id,
        publicId: updatedQuotation.publicId,
        customerPhone: updatedQuotation.customerPhone,
        customerName: updatedQuotation.customerName,
        eventDate: updatedQuotation.eventDate,
        eventTime: updatedQuotation.eventTime,
        location: updatedQuotation.location,
        notes: updatedQuotation.notes,
        subtotal: updatedQuotation.subtotal,
        discount: updatedQuotation.discount,
        deliveryCharge: updatedQuotation.deliveryCharge,
        travelCharge: updatedQuotation.travelCharge,
        gstPercent: updatedQuotation.gstPercent,
        gstAmount: updatedQuotation.gstAmount,
        grandTotal: updatedQuotation.grandTotal,
        pdfUrl: updatedQuotation.pdfUrl,
        status: updatedQuotation.status,
        items: updatedQuotation.items.map((e) => QuotationItemModel(
          experienceId: e.experienceId,
          name: e.name,
          quantity: e.quantity,
          unitPrice: e.unitPrice,
          color: e.color,
          theme: e.theme,
          notes: e.notes,
        )).toList(),
        createdAt: updatedQuotation.createdAt,
        updatedAt: updatedQuotation.updatedAt,
        customerId: updatedQuotation.customerId,
        version: updatedQuotation.version,
        publishedAt: updatedQuotation.publishedAt ?? DateTime.now(),
        publishedBy: 'Admin',
        revisionReason: null,
        revisionMessage: null,
        adminMessage: updatedQuotation.adminMessage,
        customerAction: null,
        customerActionAt: null,
        customerViewedAt: null,
        lastPublishedAt: updatedQuotation.lastPublishedAt,
        internalNotes: updatedQuotation.internalNotes,
        acceptedAt: null,
        acceptedVersion: null,
        acceptedAmount: null,
        acceptedBy: null,
        acceptedDevice: null,
        acceptedIp: null,
        consentTextVersion: null,
      );

      await db.collection(AppCollections.quotations).doc(quotation.id).set(model.toJson());
      await deleteQuotationDraft(quotation.id);

      // Price Change Message
      final oldGrandTotal = (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ?? 0.0;
      final newGrandTotal = model.grandTotal;
      if (oldGrandTotal != newGrandTotal) {
        await _postSystemMessage(
          quotation.id,
          'Price updated from ₹${oldGrandTotal.toStringAsFixed(0)} to ₹${newGrandTotal.toStringAsFixed(0)}.',
          'priceChange',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
        );
      }

      // Revision Message
      await _postSystemMessage(
        quotation.id,
        'Revised proposal version $newVersion published by Admin. Notes: ${updatedQuotation.adminMessage ?? 'No notes'}',
        'revision',
        senderId: 'admin',
        senderName: 'Admin',
        senderRole: 'admin',
      );

      final customerId = updatedQuotation.customerId;
      if (customerId.isNotEmpty) {
        await db.collection(AppCollections.customerNotifications).add({
          'customerId': customerId,
          'title': 'Proposal Updated',
          'body': 'Admin published a revised proposal for invoice ${updatedQuotation.publicId}.',
          'type': 'quotation_updated',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
          'branch': updatedQuotation.location,
          'quotationId': quotation.id,
        });

        await db.collection(AppCollections.customerActivity).add({
          'customerId': customerId,
          'status': 'Quotation',
          'updatedAt': DateTime.now().toIso8601String(),
          'details': 'Admin published revised proposal version $newVersion.',
        });

        await _writeAuditLog(
          action: 'Revision Published',
          user: 'Admin',
          role: 'admin',
          version: newVersion,
          quotationId: quotation.id,
          details: 'Admin published revised proposal version $newVersion.',
        );
      }
    } catch (e) {
      throw ServerFailure("Failed to publish revision: ${e.toString()}");
    }
  }

  Future<List<QuotationVersion>> _getVersionsForQuotation(String quotationId, List<String> legacyHistory, List<QuotationItem> currentItems) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('quotation_versions')
          .where('quotationId', isEqualTo: quotationId)
          .orderBy('versionNumber', descending: true)
          .get();
      
      if (snap.docs.isEmpty && legacyHistory.isNotEmpty) {
        return _migrateLegacyHistory(quotationId, legacyHistory, currentItems);
      }
      
      return snap.docs
          .map((doc) => QuotationVersionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<QuotationVersion> _migrateLegacyHistory(String quotationId, List<String> legacyHistory, List<QuotationItem> currentItems) {
    final list = <QuotationVersion>[];
    for (var histStr in legacyHistory) {
      try {
        final json = jsonDecode(histStr) as Map<String, dynamic>;
        final versionNum = json['version'] as int? ?? 1;
        
        final rawItems = json['items'] as List? ?? [];
        final itemsList = rawItems
            .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final version = QuotationVersion(
          id: '${quotationId}_$versionNum',
          quotationId: quotationId,
          versionNumber: versionNum,
          items: itemsList.isEmpty ? currentItems : itemsList,
          subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
          discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
          gstPercent: (json['gst_percent'] ?? json['gstPercent'] as num?)?.toDouble() ?? 18.0,
          gstAmount: (json['gst_amount'] ?? json['gstAmount'] as num?)?.toDouble() ?? 0.0,
          deliveryCharge: (json['delivery_charge'] ?? json['deliveryCharge'] ?? json['delivery'] as num?)?.toDouble() ?? 0.0,
          travelCharge: (json['travel_charge'] ?? json['travelCharge'] as num?)?.toDouble() ?? 0.0,
          grandTotal: (json['grand_total'] ?? json['grandTotal'] as num?)?.toDouble() ?? 0.0,
          adminMessage: json['adminMessage'] ?? json['admin_message'],
          publishedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
          publishedBy: json['editor'] ?? 'Admin',
          pdfUrl: json['pdf_url'] ?? json['pdfUrl'] ?? '',
          revisionReason: json['reason'] ?? 'Legacy Version',
        );
        list.add(version);
        
        FirebaseFirestore.instance
            .collection('quotation_versions')
            .doc(version.id)
            .set(QuotationVersionModel(
              id: version.id,
              quotationId: version.quotationId,
              versionNumber: version.versionNumber,
              items: version.items,
              subtotal: version.subtotal,
              discount: version.discount,
              gstPercent: version.gstPercent,
              gstAmount: version.gstAmount,
              deliveryCharge: version.deliveryCharge,
              travelCharge: version.travelCharge,
              grandTotal: version.grandTotal,
              adminMessage: version.adminMessage,
              publishedAt: version.publishedAt,
              publishedBy: version.publishedBy,
              pdfUrl: version.pdfUrl,
              revisionReason: version.revisionReason,
            ).toJson());
      } catch (_) {}
    }
    list.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    return list;
  }

  Future<void> _postSystemMessage(
    String quotationId,
    String content,
    String type, {
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('quotation_messages').doc();
      await docRef.set({
        'quotationId': quotationId,
        'senderId': senderId ?? 'system',
        'senderName': senderName ?? 'System',
        'senderRole': senderRole ?? 'system',
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'isReadByAdmin': senderRole == 'admin',
        'isReadByClient': senderRole == 'client',
        'attachments': [],
      });
    } catch (_) {}
  }

  @override
  Future<void> unlockQuotation(String id, String superAdminName) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection(AppCollections.quotations).doc(id).update({
        'isFinancialLocked': false,
        'isPermanentlyLocked': false,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Write unlock audit log
      await db.collection('activity_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'action': 'Quotation Unlocked',
        'quotationId': id,
        'details': 'Quotation unlocked by Super Admin: $superAdminName',
        'user': superAdminName,
      });

      // Post system message to quotation chat
      await _postSystemMessage(
        id,
        'Proposal unlocked by Super Admin: $superAdminName.',
        'system',
        senderId: 'admin',
        senderName: 'Super Admin',
        senderRole: 'admin',
      );
    } catch (e) {
      throw ServerFailure("Failed to unlock quotation: ${e.toString()}");
    }
  }

  Future<void> _writeAuditLog({
    required String action,
    required String user,
    required String role,
    required int version,
    required String quotationId,
    required String details,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': action,
        'user': user,
        'role': role,
        'timestamp': FieldValue.serverTimestamp(),
        'version': version,
        'quotationId': quotationId,
        'details': details,
      });
    } catch (_) {}
  }
}
