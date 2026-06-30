class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });
}
