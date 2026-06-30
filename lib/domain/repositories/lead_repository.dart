import '../entities/lead.dart';

abstract class LeadRepository {
  Future<Lead> createLead(Lead lead);
  Future<List<Lead>> getLeads();
  Future<void> updateLeadStatus(String id, String status);
}
