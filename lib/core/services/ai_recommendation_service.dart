/// Recommendation outputs from the AI engine.
class AiRecommendation {
  final String packageRecommendation;
  final List<String> recommendedServices;
  final double estimatedCost;

  const AiRecommendation({
    required this.packageRecommendation,
    required this.recommendedServices,
    required this.estimatedCost,
  });
}

/// A deterministic ruleset AI engine that processes budget and guest counts
/// to recommend optimal decoration packages and supporting services.
class AiRecommendationService {
  AiRecommendationService._();

  /// Evaluates target metrics to generate tailored recommendations.
  static AiRecommendation getRecommendation({
    required double budget,
    required int guests,
    required String eventType,
  }) {
    String package = 'Basic Decoration';
    final services = <String>['Event Coordinator Mapping'];
    double baseCost = 15000;

    // Package profiling rules
    if (budget >= 100000) {
      package = 'Grand Royal Floral Stage Decoration';
      baseCost = 85000;
    } else if (budget >= 50000) {
      package = 'Premium Classic Traditional Theme';
      baseCost = 40000;
    } else if (budget >= 25000) {
      package = 'Minimalist Elegant LED Light Theme';
      baseCost = 20000;
    }

    // Guest profiling rules
    if (guests >= 300) {
      services.addAll(['Main Stage Photographer', 'Videography Drone Team', 'Stage Sound System Setup']);
      baseCost += 35000;
    } else if (guests >= 100) {
      services.addAll(['Photographer (4 Hours)', 'Ambient Lighting Team']);
      baseCost += 15000;
    } else {
      services.add('Decor Setup Crew');
      baseCost += 5000;
    }

    return AiRecommendation(
      packageRecommendation: package,
      recommendedServices: services,
      estimatedCost: baseCost,
    );
  }
}
