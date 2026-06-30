import '../entities/quotation.dart';
import '../repositories/quotation_repository.dart';

class CreateQuotation {
  final QuotationRepository repository;
  CreateQuotation(this.repository);

  Future<Quotation> call(Quotation quotation) async {
    return await repository.createQuotation(quotation);
  }
}
