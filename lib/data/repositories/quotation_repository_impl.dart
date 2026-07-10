import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/quotation_pdf_generator.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../datasources/supabase_storage_source.dart';
import '../models/quotation_model.dart';

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
      return QuotationModel.fromJson(doc.data()!, doc.id);
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

      final historyList = List<String>.from(data['versionHistory'] ?? data['version_history'] ?? []);
      final updateData = <String, dynamic>{
        'status': targetStatus.nameStr,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 1. Version snapshotting and field updates based on targetStatus
      if (targetStatus == QuotationStatus.viewed) {
        updateData['customerViewedAt'] = DateTime.now().toIso8601String();
      } else if (targetStatus == QuotationStatus.acceptedByClient) {
        updateData['customerAction'] = 'accepted';
        updateData['customerActionAt'] = DateTime.now().toIso8601String();
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
          // Creating a new version snapshot
          final previousSnapshot = {
            'version': data['version'] ?? 1,
            'status': currentStatusStr,
            'grand_total': data['grand_total'] ?? data['grandTotal'] ?? 0.0,
            'subtotal': data['subtotal'] ?? 0.0,
            'discount': data['discount'] ?? 0.0,
            'pdf_url': data['pdf_url'] ?? data['pdfUrl'] ?? '',
            'items': data['items'] ?? [],
            'updated_at': data['updated_at'] ?? data['updatedAt'] ?? DateTime.now().toIso8601String(),
            'editor': 'Admin',
            'reason': data['revisionReason'] ?? data['revision_reason'] ?? 'Admin Revision',
          };
          historyList.add(jsonEncode(previousSnapshot));

          updateData['status'] = QuotationStatus.republished.nameStr;
          updateData['version'] = (data['version'] ?? 1) + 1;
          updateData['lastPublishedAt'] = DateTime.now().toIso8601String();
          updateData['versionHistory'] = historyList;
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

          // Log to system activity logs
          await db.collection('activity_logs').add({
            'timestamp': FieldValue.serverTimestamp(),
            'action': 'Quotation Status Update',
            'quotationId': id,
            'details': logDetails,
            'user': 'System',
          });
        }

        if (notifyTitle.isNotEmpty) {
          final isToAdmin = targetStatus == QuotationStatus.acceptedByClient ||
              targetStatus == QuotationStatus.rejectedByClient ||
              targetStatus == QuotationStatus.revisionRequested;

          await db.collection(AppCollections.customerNotifications).add({
            'customerId': isToAdmin ? 'admin' : customerId,
            'title': notifyTitle,
            'body': notifyBody,
            'type': notifyType,
            'isRead': false,
            'createdAt': DateTime.now().toIso8601String(),
            'branch': data['location'] ?? '',
          });
        }
      }
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
        .map((snap) => snap.docs
            .map((doc) => QuotationModel.fromJson(doc.data(), doc.id))
            .toList());
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
        .map((snap) {
          final quotesList = snap.docs
              .map((doc) => QuotationModel.fromJson(doc.data(), doc.id))
              .toList();
          quotesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return quotesList;
        });
  }
}
