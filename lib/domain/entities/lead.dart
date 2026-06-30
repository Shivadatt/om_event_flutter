class Lead {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String requestType; // 'callback' | 'discount' | 'package' | 'meeting' | 'site_visit'
  final DateTime? eventDate;
  final double? budget;
  final String requirements;
  final String status; // 'new' | 'contacted' | 'qualified' | 'won' | 'closed'
  final String? assignedStaffId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lead({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.requestType,
    this.eventDate,
    this.budget,
    required this.requirements,
    required this.status,
    this.assignedStaffId,
    required this.createdAt,
    required this.updatedAt,
  });
}
