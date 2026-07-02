/// Entity representing company expense line items.
class ExpenseItem {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String bookingId;

  const ExpenseItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.bookingId,
  });
}
