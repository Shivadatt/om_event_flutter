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

  final String type;

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
    this.type = 'Individual',
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    String parsedPhone = (json['phone'] ?? '').toString().trim();
    if (parsedPhone.isEmpty) {
      parsedPhone = id.trim();
    }

    String parsedName = (json['name'] ?? json['full_name'] ?? '').toString().trim();
    if (parsedName.isEmpty) {
      parsedName = parsedPhone.isNotEmpty ? parsedPhone : 'Client $id';
    }

    final createdRaw = json['created_at'] ?? json['createdAt'];
    final updatedRaw = json['updated_at'] ?? json['updatedAt'];

    final parsedType = (json['type'] ?? json['customer_type'] ?? json['client_type'] ?? 'Individual').toString().trim();

    return CustomerModel(
      id: id,
      name: parsedName,
      phone: parsedPhone,
      email: (json['email'] ?? '').toString().trim(),
      address: (json['address'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      pincode: (json['pincode'] ?? '').toString().trim(),
      branch: (json['branch'] ?? '').toString().trim(),
      gender: (json['gender'] ?? '').toString().trim(),
      dateOfBirth: json['date_of_birth'] != null ? DateParser.parse(json['date_of_birth']) : null,
      profileImageUrl: (json['profile_image_url'] ?? json['profileImageUrl'] ?? json['photoUrl'] ?? '').toString().trim(),
      mapLocation: (json['map_location'] ?? json['mapLocation'] ?? '').toString().trim(),
      createdAt: DateParser.parse(createdRaw ?? updatedRaw),
      updatedAt: DateParser.parse(updatedRaw ?? createdRaw),
      type: parsedType.isNotEmpty ? parsedType : 'Individual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'type': type,
    };
  }
}
