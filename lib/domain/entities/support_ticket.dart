/// Entity representing a customer support ticket.
class SupportTicket {
  final String id;
  final String customerId;
  final String subject;
  final String status; // Open, In Progress, Closed
  final List<String> messages;
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.customerId,
    required this.subject,
    required this.status,
    required this.messages,
    required this.createdAt,
  });
}
