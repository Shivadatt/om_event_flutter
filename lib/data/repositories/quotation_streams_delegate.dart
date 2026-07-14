import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/quotation.dart';
import '../datasources/firestore_remote_source.dart';
import '../models/quotation_model.dart';
import 'quotation_helpers_delegate.dart';

/// Delegate handling lists, streams, and single quotation query fetching.
class QuotationStreamsDelegate {
  final FirestoreRemoteSource firestoreSource;
  final QuotationHelpersDelegate helpersDelegate;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  QuotationStreamsDelegate({
    required this.firestoreSource,
    required this.helpersDelegate,
  });

  /// Fetches the raw list of quotations.
  Future<List<Quotation>> getQuotations() async {
    try {
      final docs = await firestoreSource.fetchQuotations();
      return docs
          .map((doc) => QuotationModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed fetching quotations list", layer: LogLayer.repository, className: "QuotationStreamsDelegate", methodName: "getQuotations", error: e, stack: stack);
      throw ServerFailure("Failed to fetch quotations list: ${e.toString()}");
    }
  }

  /// Fetches a single quotation and maps revision snapshots.
  Future<Quotation> getQuotationByPublicId(String publicId) async {
    try {
      final doc = await firestoreSource.fetchQuotationByPublicId(publicId);
      final model = QuotationModel.fromJson(doc.data()!, doc.id);
      final versions = await helpersDelegate.getVersionsForQuotation(
        doc.id,
        model.legacyVersionHistory,
        model.items,
      );
      return model.copyWith(versions: versions);
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed querying quotation by publicId", layer: LogLayer.repository, className: "QuotationStreamsDelegate", methodName: "getQuotationByPublicId", error: e, stack: stack);
      throw ServerFailure("Quotation not found: ${e.toString()}");
    }
  }

  /// Streams all quotations.
  Stream<List<Quotation>> streamAllQuotations() {
    return _db
        .collection('quotations')
        .snapshots()
        .asyncMap((snap) async {
          final futures = snap.docs.map((doc) async {
            final model = QuotationModel.fromJson(doc.data(), doc.id);
            final versions = await helpersDelegate.getVersionsForQuotation(
              doc.id,
              model.legacyVersionHistory,
              model.items,
            );
            return model.copyWith(versions: versions);
          }).toList();
          final List<Quotation> quotesList = await Future.wait(futures);
          quotesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return quotesList;
        });
  }

  /// Streams customer quotations.
  Stream<List<Quotation>> streamCustomerQuotations(String customerId) {
    return _db
        .collection('quotations')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .asyncMap((snap) async {
          final futures = snap.docs.map((doc) async {
            final model = QuotationModel.fromJson(doc.data(), doc.id);
            final versions = await helpersDelegate.getVersionsForQuotation(
              doc.id,
              model.legacyVersionHistory,
              model.items,
            );
            return model.copyWith(versions: versions);
          }).toList();
          final List<Quotation> quotesList = await Future.wait(futures);
          quotesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return quotesList;
        });
  }
}
