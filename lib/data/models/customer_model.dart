class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
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
    required this.mapLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      mapLocation: json['map_location'] ?? json['mapLocation'] ?? '',
      createdAt:
          (json['created_at'] ?? json['createdAt']) != null
              ? DateTime.parse((json['created_at'] ?? json['createdAt']))
              : DateTime.now(),
      updatedAt:
          (json['updated_at'] ?? json['updatedAt']) != null
              ? DateTime.parse((json['updated_at'] ?? json['updatedAt']))
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'map_location': mapLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
