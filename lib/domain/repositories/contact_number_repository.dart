import '../entities/contact_number_entity.dart';

abstract class ContactNumberRepository {
  Stream<List<ContactNumberEntity>> streamContactNumbers();
  Future<void> saveContactNumbers(List<ContactNumberEntity> numbers);
}
