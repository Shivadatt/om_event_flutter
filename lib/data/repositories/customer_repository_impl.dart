import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final SupabaseClient _client = Supabase.instance.client;

  CustomerRepositoryImpl();

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final response = await _client.from('customers').select();
    return (response as List)
        .map((row) => CustomerModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final payload = SupabaseMapper.toSnakeCase(customer.toJson());
    await _client.from('customers').update(payload).eq('id', customer.phone);
  }

  @override
  Future<void> deleteCustomer(String phone) async {
    await _client.from('customers').delete().eq('id', phone);
  }
}
