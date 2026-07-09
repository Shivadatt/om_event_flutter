part of '../quotation_controller.dart';

extension QuotationPricing on QuotationController {
  // Branded Client-side PDF Invoice Generator using pdf package
  Future<List<int>> generateInvoicePdf(Quotation quote) async {
    return await QuotationPdfGenerator.generate(quote);
  }
}
