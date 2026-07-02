class CustomerLead {
  final String id;
  final String customerId;
  final String leadNumber;
  final DateTime date;
  final String service;
  final String branch;
  final double budget;
  final DateTime eventDate;
  final String status;
  final String adminNotes;

  const CustomerLead({
    required this.id,
    required this.customerId,
    required this.leadNumber,
    required this.date,
    required this.service,
    required this.branch,
    required this.budget,
    required this.eventDate,
    required this.status,
    this.adminNotes = '',
  });
}
