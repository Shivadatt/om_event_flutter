import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class SubmitLead {
  final LeadRepository repository;
  SubmitLead(this.repository);

  Future<Lead> call(Lead lead) async {
    return await repository.createLead(lead);
  }
}
