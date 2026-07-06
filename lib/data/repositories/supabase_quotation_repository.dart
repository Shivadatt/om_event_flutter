import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../models/quotation_model.dart';

class SupabaseQuotationRepository implements QuotationRepository {
  final SupabaseClient _client = Supabase.instance.client;

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
        items: quotation.items
            .map((e) => QuotationItemModel(
                  experienceId: e.experienceId,
                  name: e.name,
                  quantity: e.quantity,
                  unitPrice: e.unitPrice,
                  color: e.color,
                  theme: e.theme,
                  notes: e.notes,
                ))
            .toList(),
        createdAt: quotation.createdAt,
        updatedAt: quotation.updatedAt,
      );

      final payload = SupabaseMapper.toSnakeCase(model.toJson());
      // Convert nested list items of QuotationItemModel to JSON List
      payload['items'] = model.items.map((e) => (e as QuotationItemModel).toJson()).toList();

      await _client.from('quotations').upsert({
        'id': quotation.id,
        ...payload,
      });

      // Upsert CRM Customer record
      final customerPayload = {
        'phone': quotation.customerPhone,
        'name': quotation.customerName,
        'email': '',
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _client.from('customers').upsert(customerPayload, onConflict: 'phone');

      return model;
    } catch (e) {
      throw ServerFailure("Failed to create quotation: ${e.toString()}");
    }
  }

  @override
  Future<String> uploadQuotationPdf(String publicId, List<int> pdfBytes) async {
    try {
      final filePath = 'quotes/$publicId.pdf';
      await _client.storage.from('gallery').uploadBinary(
            filePath,
            Uint8List.fromList(pdfBytes),
            fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
          );
      return _client.storage.from('gallery').getPublicUrl(filePath);
    } catch (e) {
      throw ServerFailure("Failed to upload quotation proposal PDF: ${e.toString()}");
    }
  }

  @override
  Future<List<Quotation>> getQuotations() async {
    try {
      final response = await _client
          .from('quotations')
          .select()
          .order('created_at', ascending: false);

      return response
          .map((row) => QuotationModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
          .toList();
    } catch (e) {
      throw ServerFailure("Failed to fetch quotations list: ${e.toString()}");
    }
  }

  @override
  Future<Quotation> getQuotationByPublicId(String publicId) async {
    try {
      final response = await _client
          .from('quotations')
          .select()
          .eq('public_id', publicId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Quotation not found.');
      }

      return QuotationModel.fromJson(SupabaseMapper.toCamelCase(response), response['id'] ?? '');
    } catch (e) {
      throw ServerFailure("Quotation not found: ${e.toString()}");
    }
  }

  @override
  Future<void> updateQuotationStatus(String id, String status) async {
    try {
      await _client
          .from('quotations')
          .update({'status': status})
          .eq('id', id);
    } catch (e) {
      throw ServerFailure("Failed to update status: ${e.toString()}");
    }
  }
}
