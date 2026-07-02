/// Entity representing discount coupon rules.
class Coupon {
  final String id;
  final String code;
  final double discount;
  final DateTime validity;
  final int usageLimit;
  final String branch;

  const Coupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.validity,
    required this.usageLimit,
    required this.branch,
  });
}
