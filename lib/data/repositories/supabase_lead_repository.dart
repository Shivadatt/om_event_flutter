import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../models/lead_model.dart';

class SupabaseLeadRepository implements LeadRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<Lead> createLead(Lead lead) async {
    try {
      final leadId = lead.id.isEmpty 
          ? 'ld_${DateTime.now().millisecondsSinceEpoch}_${lead.phone.hashCode.abs()}' 
          : lead.id;

      final model = LeadModel(
        id: leadId,
        name: lead.name,
        phone: lead.phone,
        email: lead.email,
        requestType: lead.requestType,
        eventDate: lead.eventDate,
        budget: lead.budget,
        requirements: lead.requirements,
        status: lead.status,
        assignedStaffId: lead.assignedStaffId,
        createdAt: lead.createdAt,
        updatedAt: lead.updatedAt,
      );

      final payload = SupabaseMapper.toSnakeCase(model.toJson());
      
      await _client.from('leads').upsert({
        'id': leadId,
        ...payload,
      });

      return model;
    } catch (e) {
      throw ServerFailure("Failed to submit inquiry: ${e.toString()}");
    }
  }

  @override
  Future<List<Lead>> getLeads() async {
    try {
      final response = await _client
          .from('leads')
          .select()
          .order('created_at', ascending: false);

      return response
          .map((row) => LeadModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
          .toList();
    } catch (e) {
      throw ServerFailure("Failed to retrieve inquiries list: ${e.toString()}");
    }
  }

  @override
  Future<void> updateLeadStatus(String id, String status) async {
    try {
      await _client
          .from('leads')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw ServerFailure("Failed to update inquiry status: ${e.toString()}");
    }
  }
}
