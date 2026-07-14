import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_collections.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../datasources/supabase_storage_source.dart';
import '../models/quotation_model.dart';
import '../../core/services/supabase_edge_functions.dart';
import 'quotation_drafts_delegate.dart';
import 'quotation_helpers_delegate.dart';
import 'quotation_revisions_delegate.dart';
import 'quotation_streams_delegate.dart';

/// Implementation of the QuotationRepository utilizing delegates for SOLID separation of concerns.
class QuotationRepositoryImpl implements QuotationRepository {
  final FirestoreRemoteSource firestoreSource;
  final SupabaseStorageSource? supabaseSource;

  late final QuotationDraftsDelegate _draftsDelegate;
  late final QuotationHelpersDelegate _helpersDelegate;
  late final QuotationStreamsDelegate _streamsDelegate;
  late final QuotationRevisionsDelegate _revisionsDelegate;

  QuotationRepositoryImpl({required this.firestoreSource, this.supabaseSource}) {
    _draftsDelegate = QuotationDraftsDelegate();
    _helpersDelegate = QuotationHelpersDelegate();
    _streamsDelegate = QuotationStreamsDelegate(
      firestoreSource: firestoreSource,
      helpersDelegate: _helpersDelegate,
    );
    _revisionsDelegate = QuotationRevisionsDelegate(
      firestoreSource: firestoreSource,
      supabaseSource: supabaseSource,
      helpersDelegate: _helpersDelegate,
    );
  }

  @override
  Future<Quotation> createQuotation(Quotation quotation) async {
    try {
      AppLogger.info("Starting quotation creation for client UID: ${quotation.customerId}", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "createQuotation");
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
        updatedAt: quotation.updatedAt,
      );

      await firestoreSource.submitQuotation(model.toJson(), quotation.id);

      SupabaseEdgeFunctions.to.invoke('quotation-event', {
        'eventType': 'created',
        'quoteId': quotation.id.isEmpty ? model.id : quotation.id,
      });

      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      await firestoreSource.upsertCustomer(
        phone: quotation.customerPhone,
        name: quotation.customerName,
        email: userEmail,
      );

      AppLogger.success("Quotation created successfully", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "createQuotation");
      return model;
    } catch (e, stack) {
      AppLogger.errorDetailed("Quotation creation failed", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "createQuotation", error: e, stack: stack);
      throw ServerFailure("Failed to create quotation: ${e.toString()}");
    }
  }

  @override
  Future<String> uploadQuotationPdf(String publicId, List<int> pdfBytes) async {
    try {
      if (supabaseSource == null) {
        throw const ServerFailure("Supabase Storage integration is not configured.");
      }
      final filePath = 'quotes/$publicId.pdf';
      return await supabaseSource!.uploadFile(filePath, pdfBytes, 'application/pdf');
    } catch (e, stack) {
      AppLogger.errorDetailed("PDF upload failed", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "uploadQuotationPdf", error: e, stack: stack);
      throw ServerFailure("Failed to upload quotation proposal PDF: ${e.toString()}");
    }
  }

  @override
  Future<void> updateQuotationStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance.collection(AppCollections.quotations).doc(id).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      AppLogger.success("Quotation status updated to $status", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "updateQuotationStatus");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to update status", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "updateQuotationStatus", error: e, stack: stack);
      throw ServerFailure("Failed to update status: ${e.toString()}");
    }
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

      await db.collection('activity_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'action': 'Quotation Unlocked',
        'quotationId': id,
        'details': 'Quotation unlocked by Super Admin: $superAdminName',
        'user': superAdminName,
      });

      await _helpersDelegate.postSystemMessage(
        id,
        'Proposal unlocked by Super Admin: $superAdminName.',
        'system',
        senderId: 'admin',
        senderName: 'Super Admin',
        senderRole: 'admin',
      );
      AppLogger.success("Quotation unlocked successfully", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "unlockQuotation");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to unlock quotation", layer: LogLayer.repository, className: "QuotationRepositoryImpl", methodName: "unlockQuotation", error: e, stack: stack);
      throw ServerFailure("Failed to unlock quotation: ${e.toString()}");
    }
  }

  @override
  Future<List<Quotation>> getQuotations() => _streamsDelegate.getQuotations();

  @override
  Future<Quotation> getQuotationByPublicId(String publicId) => _streamsDelegate.getQuotationByPublicId(publicId);

  @override
  Stream<List<Quotation>> streamAllQuotations() => _streamsDelegate.streamAllQuotations();

  @override
  Stream<List<Quotation>> streamCustomerQuotations(String customerId) => _streamsDelegate.streamCustomerQuotations(customerId);

  @override
  Future<void> saveQuotationDraft(Quotation quotation) => _draftsDelegate.saveQuotationDraft(quotation);

  @override
  Future<Quotation?> getQuotationDraft(String id) => _draftsDelegate.getQuotationDraft(id);

  @override
  Future<void> deleteQuotationDraft(String id) => _draftsDelegate.deleteQuotationDraft(id);

  @override
  Future<void> publishQuotationRevision(Quotation quotation) => _revisionsDelegate.publishQuotationRevision(quotation);
}
