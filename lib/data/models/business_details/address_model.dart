part of '../business_details_model.dart';

class AddressModel {
  static AddressEntity fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] ?? '',
      addressTitle: json['addressTitle'] ?? '',
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      landmark: json['landmark'] ?? '',
      googleMapsLink: json['googleMapsLink'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(AddressEntity entity) {
    return {
      'id': entity.id,
      'addressTitle': entity.addressTitle,
      'street': entity.street,
      'area': entity.area,
      'city': entity.city,
      'district': entity.district,
      'state': entity.state,
      'country': entity.country,
      'pincode': entity.pincode,
      'landmark': entity.landmark,
      'googleMapsLink': entity.googleMapsLink,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
    };
  }
}
