/// Entity representing assigned event coordinators.
class Coordinator {
  final String id;
  final String name;
  final String phone;
  final String photoUrl;
  final bool isActive;

  const Coordinator({
    required this.id,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.isActive,
  });
}
