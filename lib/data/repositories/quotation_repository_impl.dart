import '../../core/errors/failures.dart';
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
      await firestoreSource.updateQuotationStatus(id, status);
    } catch (e) {
      throw ServerFailure("Failed to update status: ${e.toString()}");
    }
  }
}
