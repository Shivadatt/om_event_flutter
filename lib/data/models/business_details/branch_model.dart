part of '../business_details_model.dart';

class BranchModel {
  static BranchEntity fromJson(Map<String, dynamic> json) {
    return BranchEntity(
      id: json['id'] ?? '',
      branchName: json['branchName'] ?? '',
      branchManager: json['branchManager'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      googleMapUrl: json['googleMapUrl'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      workingHours: json['workingHours'] ?? '',
      openingDays: json['openingDays'] ?? '',
      displayOrder: json['displayOrder'] ?? 1,
      isActive: json['isActive'] ?? true,
      instagram: json['instagram'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(BranchEntity entity) {
    return {
      'id': entity.id,
      'branchName': entity.branchName,
      'branchManager': entity.branchManager,
      'phoneNumber': entity.phoneNumber,
      'whatsapp': entity.whatsapp,
      'email': entity.email,
      'fullAddress': entity.fullAddress,
      'googleMapUrl': entity.googleMapUrl,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
      'workingHours': entity.workingHours,
      'openingDays': entity.openingDays,
      'displayOrder': entity.displayOrder,
      'isActive': entity.isActive,
      'instagram': entity.instagram,
    };
  }
}
