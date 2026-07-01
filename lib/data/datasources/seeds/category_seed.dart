/// Seed data configurations for decoration category catalog bootstrapping.
class CategorySeed {
  /// Static configuration list of core category entities.
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'birthday',
      'name': 'Birthday Celebrations',
      'slug': 'birthday',
      'description': 'Joyful themes designed around their favorite things.',
      'icon': '🎈',
      'color': '#e58b9d',
      'image_url': 'assets/images/birthday.jpg',
      'sort_order': 0,
      'is_active': true,
    },
    {
      'id': 'wedding',
      'name': 'Wedding & Engagement',
      'slug': 'wedding',
      'description':
          'Elegant stages and entrances for once-in-a-lifetime vows.',
      'icon': '💍',
      'color': '#c79b61',
      'image_url': 'assets/images/wedding-stage.jpg',
      'sort_order': 1,
      'is_active': true,
    },
    {
      'id': 'baby',
      'name': 'Baby Celebrations',
      'slug': 'baby',
      'description':
          'Soft, playful worlds for showers and welcome-home moments.',
      'icon': '☁',
      'color': '#75a9a6',
      'image_url': 'assets/images/welcomebaby.jpg',
      'sort_order': 2,
      'is_active': true,
    },
    {
      'id': 'corporate',
      'name': 'Corporate Events',
      'slug': 'corporate',
      'description': 'Polished launches, openings, and branded experiences.',
      'icon': '✦',
      'color': '#7c86bd',
      'image_url': 'assets/images/luxury-reception.jpg',
      'sort_order': 3,
      'is_active': true,
    },
    {
      'id': 'proposal',
      'name': 'Surprise & Proposal',
      'slug': 'proposal',
      'description': 'Thoughtful romantic settings with a cinematic reveal.',
      'icon': '♡',
      'color': '#c96f64',
      'image_url': 'assets/images/proposal-candles.jpg',
      'sort_order': 4,
      'is_active': true,
    },
    {
      'id': 'entries',
      'name': 'Grand Entries',
      'slug': 'entries',
      'description': 'Fog, flowers, cold fire, and choreography for impact.',
      'icon': '⚡',
      'color': '#a483c0',
      'image_url': 'assets/images/SmokeEntry.jpg',
      'sort_order': 5,
      'is_active': true,
    },
  ];
}
