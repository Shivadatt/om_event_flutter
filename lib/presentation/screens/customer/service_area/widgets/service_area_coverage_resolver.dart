import 'package:flutter/material.dart';

class ServiceAreaCoverageResolver {
  static Map<String, dynamic> resolveCoverage(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();

    // ZONE 1: Primary Delivery Hubs
    if (query.contains('kadi') ||
        query == '382715' ||
        query.contains('kalol') ||
        query == '382721' ||
        query.contains('mehsana') ||
        query.startsWith('3840') ||
        query.contains('nandasan') ||
        query == '382725' ||
        query.contains('ahmedabad') ||
        query.startsWith('380') ||
        query.contains('gandhinagar') ||
        query.startsWith('3820')) {
      return {
        'zone': 'Zone 1: Primary Delivery Hubs',
        'status': 'FULL SERVICE GUARANTEED',
        'color': const Color(0xFF4EBA7A),
        'fee': '₹500 standard delivery / Complimentary on luxury packages',
        'leadTime': '7 Days Standard Advance Notice',
        'details':
            'Direct coverage from our Kadi Showroom & Studio and Ahmedabad operations hub. Full stage setups, bespoke decor, and dedicated on-site supervisors are guaranteed.',
      };
    }

    // ZONE 2: Extended Gujarat Districts
    if (query.contains('sanand') ||
        query == '382110' ||
        query.contains('bavla') ||
        query == '382220' ||
        query.contains('viramgam') ||
        query == '382150' ||
        query.contains('himatnagar') ||
        query == '383001' ||
        query.contains('vijapur') ||
        query == '382870' ||
        query.contains('unjha') ||
        query == '384170' ||
        query.contains('patan') ||
        query.startsWith('3842') ||
        query.contains('surendranagar') ||
        query == '363001' ||
        query.contains('thangadh') ||
        query == '363530' ||
        query.contains('chotila') ||
        query == '363520' ||
        query.contains('wadhwan') ||
        query == '363030' ||
        query.contains('rajkot') ||
        query.startsWith('360')) {
      return {
        'zone': 'Zone 2: Extended Gujarat Districts',
        'status': 'EXTENDED COVERAGE GUARANTEED',
        'color': const Color(0xFFE2C074),
        'fee':
            'Nominal travel allowance (₹15/km or flat outstation allowance)',
        'leadTime': '7-10 Days Advance Notice',
        'details':
            'Serviced directly via our Thangadh Creative Base and regional deployment teams. Seamless equipment transport and dedicated on-site crew coordination.',
      };
    }

    // ZONE 3: Royal Heritage & Destinations
    return {
      'zone': 'Zone 3: Royal Heritage & Destinations',
      'status': 'BESPOKE OUTSTATION BOOKING',
      'color': const Color(0xFF64B5F6),
      'fee': 'Custom logistics & accommodation quoted upon request',
      'leadTime': '15-30 Days Advance Notice',
      'details':
          'For royal destinations, palaces, and heritage venues across Gujarat, Rajasthan, and beyond (Udaipur, Mount Abu, Surat, Bhavnagar, Jamnagar), custom logistics and accommodation are quoted upon request.',
    };
  }
}
