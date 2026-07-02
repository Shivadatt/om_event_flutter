import '../../domain/entities/contact_number_entity.dart';
import '../models/contact_number_model.dart';

class ContactNumberMapper {
  static ContactNumberEntity toEntity(ContactNumberModel model) {
    return ContactNumberEntity(
      id: model.id,
      label: model.label,
      number: model.number,
      isPrimary: model.isPrimary,
      isActive: model.isActive,
      displayOrder: model.displayOrder,
    );
  }

  static ContactNumberModel toModel(ContactNumberEntity entity) {
    return ContactNumberModel(
      id: entity.id,
      label: entity.label,
      number: entity.number,
      isPrimary: entity.isPrimary,
      isActive: entity.isActive,
      displayOrder: entity.displayOrder,
    );
  }
}
