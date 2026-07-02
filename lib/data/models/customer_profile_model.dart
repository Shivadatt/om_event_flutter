import '../../domain/entities/customer_profile.dart';
import '../../core/utils/date_parser.dart';

class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.email,
    required super.gender,
    super.dateOfBirth,
    required super.address,
    required super.city,
    required super.state,
    required super.pincode,
    required super.branch,
    required super.profileImageUrl,
    required super.createdAt,
    super.lastLogin,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerProfileModel(
      id: id,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] != null ? DateParser.parse(json['date_of_birth']) : null,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      branch: json['branch'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      createdAt: DateParser.parse(json['created_at']),
      lastLogin: json['last_login'] != null ? DateParser.parse(json['last_login']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'branch': branch,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}
