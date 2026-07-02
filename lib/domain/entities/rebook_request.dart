class RebookRequest {
  final String id;
  final String customerId;
  final String previousBookingId;
  final DateTime newDate;
  final String status;
  final DateTime createdAt;

  const RebookRequest({
    required this.id,
    required this.customerId,
    required this.previousBookingId,
    required this.newDate,
    required this.status,
    required this.createdAt,
  });
}
