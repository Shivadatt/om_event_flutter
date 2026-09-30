class CustomerLead {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String leadNumber;
  final DateTime date;
  final String service;
  final String branch;
  final double budget;
  final DateTime eventDate;
  final String status;
  final String adminNotes;
  final String serviceId;
  final String serviceSlug;
  final String imageUrl;
  final String categoryId;

  const CustomerLead({
    required this.id,
    required this.customerId,
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    required this.leadNumber,
    required this.date,
    required this.service,
    required this.branch,
    required this.budget,
    required this.eventDate,
    required this.status,
    this.adminNotes = '',
    this.serviceId = '',
    this.serviceSlug = '',
    this.imageUrl = '',
    this.categoryId = '',
  });
}

