class CustomerBooking {
  final String id;
  final String customerId;
  final String bookingNumber;
  final String eventName;
  final String package;
  final String branch;
  final String decorationType;
  final DateTime date;
  final String venue;
  final double amount;
  final double advancePaid;
  final double remainingAmount;
  final String assignedBranch;
  final String assignedContact;
  final String status;

  const CustomerBooking({
    required this.id,
    required this.customerId,
    required this.bookingNumber,
    required this.eventName,
    required this.package,
    required this.branch,
    required this.decorationType,
    required this.date,
    required this.venue,
    required this.amount,
    required this.advancePaid,
    required this.remainingAmount,
    required this.assignedBranch,
    required this.assignedContact,
    required this.status,
  });
}
