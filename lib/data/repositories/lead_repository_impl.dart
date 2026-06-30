import '../../core/errors/failures.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../models/lead_model.dart';

class LeadRepositoryImpl implements LeadRepository {
  final FirestoreRemoteSource firestoreSource;
  LeadRepositoryImpl(this.firestoreSource);

  @override
  Future<Lead> createLead(Lead lead) async {
    try {
      final model = LeadModel(
        id: lead.id,
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

      final docRef = await firestoreSource.submitLead(model.toJson());
      // Return a new model with the generated document ID
      return LeadModel(
        id: docRef.id,
        name: model.name,
        phone: model.phone,
        email: model.email,
        requestType: model.requestType,
        eventDate: model.eventDate,
        budget: model.budget,
        requirements: model.requirements,
        status: model.status,
        assignedStaffId: model.assignedStaffId,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );
    } catch (e) {
      throw ServerFailure("Failed to submit inquiry: ${e.toString()}");
    }
  }

  @override
  Future<List<Lead>> getLeads() async {
    try {
      final docs = await firestoreSource.fetchLeads();
      return docs.map((doc) => LeadModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      throw ServerFailure("Failed to retrieve inquiries list: ${e.toString()}");
    }
  }

  @override
  Future<void> updateLeadStatus(String id, String status) async {
    try {
      await firestoreSource.updateLeadStatus(id, status);
    } catch (e) {
      throw ServerFailure("Failed to update inquiry status: ${e.toString()}");
    }
  }
}
