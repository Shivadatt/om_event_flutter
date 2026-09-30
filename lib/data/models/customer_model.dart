import '../../core/utils/date_parser.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String branch;
  final String gender;
  final DateTime? dateOfBirth;
  final String profileImageUrl;
  final String mapLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    this.state = '',
    this.pincode = '',
    this.branch = '',
    this.gender = '',
    this.dateOfBirth,
    this.profileImageUrl = '',
    required this.mapLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      name: json['name'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      branch: json['branch'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] != null ? DateParser.parse(json['date_of_birth']) : null,
      profileImageUrl: json['profile_image_url'] ?? json['profileImageUrl'] ?? json['photoUrl'] ?? '',
      mapLocation: json['map_location'] ?? json['mapLocation'] ?? '',
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateParser.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'branch': branch,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'profileImageUrl': profileImageUrl,
      'map_location': mapLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
