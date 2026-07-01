/// Seed data configurations for verified customer reviews.
class ReviewSeed {
  /// Static configuration list of published review templates.
  static const List<Map<String, dynamic>> reviews = [
    {
      'id': 'rev-1',
      'customer_name': 'Riya & Aakash',
      'event_name': 'Engagement',
      'rating': 5,
      'comment':
          'They understood the mood instantly. Every corner felt intentional, and the quotation stayed completely transparent.',
      'image_url': '',
      'is_verified': true,
      'is_published': true,
      'created_at': '2026-06-28T08:27:47Z',
    },
    {
      'id': 'rev-2',
      'customer_name': 'Meera Patel',
      'event_name': 'First Birthday',
      'rating': 5,
      'comment':
          'Beautiful execution, calm team, zero last-minute chaos. The pastel setup looked even better in person.',
      'image_url': '',
      'is_verified': true,
      'is_published': true,
      'created_at': '2026-06-28T08:27:47Z',
    },
    {
      'id': 'rev-3',
      'customer_name': 'Arjun Mehta',
      'event_name': 'Brand Launch',
      'rating': 5,
      'comment':
          'Professional from site visit through teardown. Their timing and attention to brand details were excellent.',
      'image_url': '',
      'is_verified': true,
      'is_published': true,
      'created_at': '2026-06-28T08:27:47Z',
    },
  ];
}
