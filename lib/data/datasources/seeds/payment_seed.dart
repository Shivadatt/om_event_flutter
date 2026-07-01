/// Seed data configurations for payments, quotations, and contract line items.
class PaymentSeed {
  /// Static configuration list of billing proposals.
  static const List<Map<String, dynamic>> quotations = [
    {
      'id': 'q-1',
      'public_id': '1_QmGJj-4WZ-dA',
      'customer_id': 'cust-1',
      'customer_name': 'goswami pushpdant',
      'customer_phone': '7567822153',
      'eventDate': '2026-06-30',
      'eventTime': '18:00',
      'location': 'kadi',
      'notes': '',
      'subtotal': 14900.0,
      'discount': 0.0,
      'delivery_charge': 500.0,
      'travel_charge': 0.0,
      'gst_percent': 18.0,
      'gst_amount': 2772.0,
      'grand_total': 18172.0,
      'status': 'draft',
      'created_at': '2026-06-28T09:07:54Z',
      'updated_at': '2026-06-28T09:07:54Z',
    },
  ];

  /// Static configuration list of itemized invoice lines.
  static const List<Map<String, dynamic>> quotationItems = [
    {
      'id': 'qi-1',
      'quotation_id': 'q-1',
      'experience_id': 'pastel-dream-birthday',
      'name': 'Baby Shower/Srimant Sanskar',
      'quantity': 1,
      'unit_price': 14900.0,
      'color': '',
      'theme': '',
      'notes': '',
    },
  ];
}
