import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Canonical Auth Linking fields
  final String authUid;
  final bool loginEnabled;
  final String loginMethod;
  final bool mustChangePassword;

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
    this.authUid = '',
    this.loginEnabled = false,
    this.loginMethod = 'email_password',
    this.mustChangePassword = true,
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
    final parsedAuthUid = (json['auth_uid'] ?? json['authUid'] ?? '').toString().trim();
    final parsedLoginEnabled = json['login_enabled'] == true || json['loginEnabled'] == true;
    final parsedLoginMethod = (json['login_method'] ?? json['loginMethod'] ?? 'email_password').toString().trim();
    final parsedMustChangePassword = json['must_change_password'] == true || json['mustChangePassword'] == true;

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
      authUid: parsedAuthUid,
      loginEnabled: parsedLoginEnabled,
      loginMethod: parsedLoginMethod.isNotEmpty ? parsedLoginMethod : 'email_password',
      mustChangePassword: parsedMustChangePassword,
    );
  }

  Map<String, dynamic> toJson({bool useServerTimestamps = false}) {
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
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'profileImageUrl': profileImageUrl,
      'map_location': mapLocation,
      'type': type,
      'auth_uid': authUid,
      'login_enabled': loginEnabled,
      'login_method': loginMethod,
      'must_change_password': mustChangePassword,
      'created_at': useServerTimestamps ? FieldValue.serverTimestamp() : createdAt.toIso8601String(),
      'updated_at': useServerTimestamps ? FieldValue.serverTimestamp() : updatedAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? branch,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    String? mapLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? authUid,
    bool? loginEnabled,
    String? loginMethod,
    bool? mustChangePassword,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      branch: branch ?? this.branch,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      mapLocation: mapLocation ?? this.mapLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      authUid: authUid ?? this.authUid,
      loginEnabled: loginEnabled ?? this.loginEnabled,
      loginMethod: loginMethod ?? this.loginMethod,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
