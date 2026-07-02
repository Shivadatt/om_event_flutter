/// Entity representing legal booking terms and signatures.
class BookingAgreement {
  final String id;
  final String bookingId;
  final String terms;
  final String digitalSignature; // Base64 signature path or string
  final bool accepted;

  const BookingAgreement({
    required this.id,
    required this.bookingId,
    required this.terms,
    required this.digitalSignature,
    required this.accepted,
  });
}
