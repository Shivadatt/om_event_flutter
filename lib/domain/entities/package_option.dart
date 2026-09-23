class PackageOption {
  final String id;
  final String serviceId;
  final String tier; // 'basic' | 'premium' | 'luxury'
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> features;
  final double durationHours;
  final bool isActive;
  final int sortOrder;

  const PackageOption({
    required this.id,
    required this.serviceId,
    required this.tier,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.features,
    required this.durationHours,
    this.isActive = true,
    required this.sortOrder,
  });

  double get effectivePrice => discountPrice != null && discountPrice! > 0 ? discountPrice! : price;

  factory PackageOption.fromJson(Map<String, dynamic> json, String fallbackServiceId) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final rawTier = (json['tier'] ?? json['tier_level'] ?? 'basic').toString().toLowerCase();

    return PackageOption(
      id: json['id'] ?? json['packageId'] ?? json['package_id'] ?? 'pkg_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: json['serviceId'] ?? json['service_id'] ?? fallbackServiceId,
      tier: rawTier,
      name: json['name'] ?? 'Standard Package',
      description: json['description'] ?? '',
      price: parseDouble(json['price']) ?? 0.0,
      discountPrice: parseDouble(json['discountPrice'] ?? json['discount_price']),
      features: List<String>.from(json['features'] ?? []),
      durationHours: parseDouble(json['durationHours'] ?? json['duration_hours']) ?? 3.0,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      sortOrder: (json['sortOrder'] ?? json['sort_order'] ?? 1) is num
          ? (json['sortOrder'] ?? json['sort_order']).toInt()
          : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'tier': tier,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'features': features,
      'durationHours': durationHours,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  /// Generates default fallback packages for experiences without explicitly seeded tiers
  static List<PackageOption> generateDefaults({
    required String serviceId,
    required String serviceName,
    required double basePrice,
    required double baseDuration,
  }) {
    final double safeBase = basePrice > 0 ? basePrice : 4999.0;
    final double premiumPrice = (safeBase * 1.45).roundToDouble();
    final double luxuryPrice = (safeBase * 2.20).roundToDouble();

    return [
      PackageOption(
        id: '${serviceId}_pkg_basic',
        serviceId: serviceId,
        tier: 'basic',
        name: 'Basic Elegance',
        description: 'Essential decor setup with refined aesthetics, curated palette, and standard lighting.',
        price: safeBase,
        discountPrice: null,
        features: [
          'Core backdrop design & draping',
          'Standard ambient mood lighting',
          'Coordinated color palette balloons/fabrics',
          'Setup & dismantle within 2 hours',
        ],
        durationHours: baseDuration > 0 ? baseDuration : 3.0,
        isActive: true,
        sortOrder: 1,
      ),
      PackageOption(
        id: '${serviceId}_pkg_premium',
        serviceId: serviceId,
        tier: 'premium',
        name: 'Premium Royale',
        description: 'Enhanced themed setup with organic floral accents, neon signages, and elevated stage elements.',
        price: premiumPrice,
        discountPrice: (premiumPrice * 0.92).roundToDouble(),
        features: [
          'Grand multi-tier backdrop structure',
          'Premium floral arrangements & foliage',
          'Warm LED fairy lights & custom neon signage',
          'Themed table accents & props',
          'Dedicated on-site decor coordinator',
        ],
        durationHours: (baseDuration * 1.2).clamp(3.0, 6.0),
        isActive: true,
        sortOrder: 2,
      ),
      PackageOption(
        id: '${serviceId}_pkg_luxury',
        serviceId: serviceId,
        tier: 'luxury',
        name: 'Luxury Grande',
        description: 'Complete luxury transformation with bespoke staging, exotic fresh flowers, and dynamic theatrical lighting.',
        price: luxuryPrice,
        discountPrice: (luxuryPrice * 0.88).roundToDouble(),
        features: [
          'Fully custom architectural entrance & stage',
          'Exotic imported floral installations',
          'Programmable ambient illumination & spotlights',
          'Complete venue thematic integration',
          'Dedicated senior designer & priority support',
          'Complimentary photography backdrop framing',
        ],
        durationHours: (baseDuration * 1.5).clamp(4.0, 8.0),
        isActive: true,
        sortOrder: 3,
      ),
    ];
  }
}
