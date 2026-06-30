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
      mapLocation: json['mapLocation'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
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
      'mapLocation': mapLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
