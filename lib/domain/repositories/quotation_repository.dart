import '../entities/quotation.dart';

abstract class QuotationRepository {
  Future<Quotation> createQuotation(Quotation quotation);
  Future<String> uploadQuotationPdf(String publicId, List<int> pdfBytes);
  Future<List<Quotation>> getQuotations();
  Future<Quotation> getQuotationByPublicId(String publicId);
  Future<void> updateQuotationStatus(String id, String status);
  Stream<List<Quotation>> streamAllQuotations();
  Stream<List<Quotation>> streamCustomerQuotations(String customerId);
}
