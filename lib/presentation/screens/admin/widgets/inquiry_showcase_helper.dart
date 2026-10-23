import '../../../../domain/entities/lead.dart';

class InquiryShowcaseHelper {
  static const List<String> covers = [
    'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=600',
    'https://images.unsplash.com/photo-1513151233558-d860c5398176?q=80&w=600',
    'https://images.unsplash.com/photo-1541976844346-f18aeac57b06?q=80&w=600',
    'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=600',
    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=600',
    'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=600',
    'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?q=80&w=600',
    'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=600',
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=600',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?q=80&w=600',
  ];

  static int getCrossAxisCount(double width) {
    if (width >= 900) return 3; // Desktop & Laptop (3-column)
    if (width >= 620) return 2; // Tablet (2-column)
    return 1;                  // Mobile (1-column)
  }

  static String getEventCoverUrl(int index) {
    return covers[index % covers.length];
  }

  static String cleanText(String text) {
    String cleaned = text
        .replaceAll('bWedding/b', 'Wedding')
        .replaceAll('bBirthday/b', 'Birthday')
        .replaceAll('bBaby Shower/b', 'Baby Shower')
        .replaceAll('bCandle Light/b', 'Candle Light')
        .replaceAll('bCorporate/b', 'Corporate Event')
        .replaceAll('bEngagement/b', 'Engagement');
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    final match = RegExp(r'^b(.+)/b$').firstMatch(cleaned);
    if (match != null) {
      cleaned = match.group(1) ?? cleaned;
    }
    if (cleaned.startsWith('b') && cleaned.endsWith('/b')) {
      cleaned = cleaned.substring(1, cleaned.length - 2);
    }
    return cleaned.trim().isEmpty ? 'Event Decor' : cleaned.trim();
  }

  static List<Lead> filterLeads({
    required List<Lead> allLeads,
    required String selectedStatusFilter,
    required String searchQuery,
  }) {
    final query = searchQuery.trim().toLowerCase();

    return allLeads.where((lead) {
      final status = lead.status.toLowerCase();
      if (selectedStatusFilter == 'new' && status != 'new') {
        return false;
      }
      if (selectedStatusFilter == 'contacted' && status != 'contacted') {
        return false;
      }
      if (selectedStatusFilter == 'closed' &&
          status != 'closed' &&
          status != 'won') {
        return false;
      }

      if (query.isNotEmpty) {
        final nameMatch = lead.name.toLowerCase().contains(query);
        final phoneMatch = lead.phone.toLowerCase().contains(query);
        final emailMatch = lead.email.toLowerCase().contains(query);
        final typeMatch = lead.requestType.toLowerCase().contains(query);
        final reqMatch = lead.requirements.toLowerCase().contains(query);
        if (!nameMatch &&
            !phoneMatch &&
            !emailMatch &&
            !typeMatch &&
            !reqMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
