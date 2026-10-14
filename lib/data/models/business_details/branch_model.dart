part of '../business_details_model.dart';

class BranchModel {
  static BranchEntity fromJson(Map<String, dynamic> json, [int index = 0]) {
    final rawId = (json['id'] ?? '').toString().trim();
    final rawName = (json['branchName'] ?? json['name'] ?? '').toString().trim();
    final fallbackSlug = rawName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final safeId = rawId.isNotEmpty
        ? rawId
        : (fallbackSlug.isNotEmpty ? '${fallbackSlug}_$index' : 'branch_$index');

    final rawOrder = json['displayOrder'] ?? json['display_order'];
    final displayOrder = rawOrder is int
        ? rawOrder
        : (int.tryParse(rawOrder?.toString() ?? '') ?? index);

    final rawActive = json['isActive'] ?? json['is_active'];
    final isActive = rawActive is bool
        ? rawActive
        : (rawActive?.toString().toLowerCase() != 'false');

    return BranchEntity(
      id: safeId,
      branchName: rawName.isNotEmpty ? rawName : 'Branch ${index + 1}',
      branchManager: (json['branchManager'] ?? json['manager'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? json['phone1'] ?? '').toString(),
      whatsapp: (json['whatsapp'] ?? json['whatsapp_number'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullAddress: (json['fullAddress'] ?? json['address'] ?? json['address_line'] ?? '').toString(),
      googleMapUrl: (json['googleMapUrl'] ?? json['googleMaps'] ?? json['map_url'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      workingHours: (json['workingHours'] ?? json['businessHours'] ?? '').toString(),
      openingDays: (json['openingDays'] ?? '').toString(),
      displayOrder: displayOrder,
      isActive: isActive,
      instagram: (json['instagram'] ?? json['instagram_url'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> toJson(BranchEntity entity) {
    return {
      'id': entity.id,
      'name': entity.branchName,
      'branchName': entity.branchName,
      'branchManager': entity.branchManager,
      'phone': entity.phoneNumber,
      'phoneNumber': entity.phoneNumber,
      'whatsapp': entity.whatsapp,
      'email': entity.email,
      'address_line': entity.fullAddress,
      'fullAddress': entity.fullAddress,
      'address': entity.fullAddress,
      'city': _extractCity(entity.fullAddress, entity.branchName),
      'googleMapUrl': entity.googleMapUrl,
      'googleMaps': entity.googleMapUrl,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
      'workingHours': entity.workingHours,
      'openingDays': entity.openingDays,
      'display_order': entity.displayOrder,
      'displayOrder': entity.displayOrder,
      'is_active': entity.isActive,
      'isActive': entity.isActive,
      'instagram': entity.instagram,
      'instagram_url': entity.instagram,
    };
  }

  static String _extractCity(String fullAddress, String branchName) {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      final c = parts[parts.length - 2].trim();
      if (c.isNotEmpty) return c;
    }
    final nameCity = branchName.split('(').first.trim();
    if (nameCity.isNotEmpty && nameCity.length <= 25) {
      return nameCity;
    }
    return 'Office';
  }
}
