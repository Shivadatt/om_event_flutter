class CustomerProfile {
  final String id; // Auth UID
  final String fullName;
  final String phone;
  final String email;
  final String gender;
  final DateTime? dateOfBirth;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String branch;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const CustomerProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.gender,
    this.dateOfBirth,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.branch,
    required this.profileImageUrl,
    required this.createdAt,
    this.lastLogin,
  });
}
