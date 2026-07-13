part of '../settings_entities.dart';

class PricingSettings {
  final double gst;
  final double deliveryCharge;
  final double travelCharge;
  final double discount;
  final List<dynamic> coupons;
  final double advanceAmount;

  const PricingSettings({
    required this.gst,
    required this.deliveryCharge,
    required this.travelCharge,
    required this.discount,
    required this.coupons,
    required this.advanceAmount,
  });

  factory PricingSettings.defaultVal() {
    return const PricingSettings(
      gst: 18.0,
      deliveryCharge: 500.0,
      travelCharge: 0.0,
      discount: 0.0,
      coupons: [],
      advanceAmount: 0.0,
    );
  }
}

class BookingSettings {
  final List<dynamic> bookingRules;
  final int advanceDays;
  final String workingHours;
  final List<dynamic> cancellationRules;
  final List<dynamic> refundRules;

  const BookingSettings({
    required this.bookingRules,
    required this.advanceDays,
    required this.workingHours,
    required this.cancellationRules,
    required this.refundRules,
  });

  factory BookingSettings.defaultVal() {
    return const BookingSettings(
      bookingRules: [],
      advanceDays: 7,
      workingHours: "9:00 AM - 8:00 PM",
      cancellationRules: [],
      refundRules: [],
    );
  }
}

class StatisticsSettings {
  final int completedEvents;
  final int happyClients;
  final int cities;
  final int years;

  const StatisticsSettings({
    required this.completedEvents,
    required this.happyClients,
    required this.cities,
    required this.years,
  });

  factory StatisticsSettings.defaultVal() {
    return const StatisticsSettings(
      completedEvents: 500,
      happyClients: 480,
      cities: 12,
      years: 8,
    );
  }
}

class FeatureFlagsSettings {
  final bool enableReviews;
  final bool enableGallery;
  final bool enableBooking;
  final bool enablePayments;
  final bool enableCart;
  final bool enableQuotes;
  final bool enableAnalytics;

  const FeatureFlagsSettings({
    required this.enableReviews,
    required this.enableGallery,
    required this.enableBooking,
    required this.enablePayments,
    required this.enableCart,
    required this.enableQuotes,
    required this.enableAnalytics,
  });

  factory FeatureFlagsSettings.defaultVal() {
    return const FeatureFlagsSettings(
      enableReviews: true,
      enableGallery: true,
      enableBooking: true,
      enablePayments: false,
      enableCart: true,
      enableQuotes: true,
      enableAnalytics: false,
    );
  }
}

class MaintenanceSettings {
  final bool maintenanceMode;
  final String message;
  final String eta;

  const MaintenanceSettings({
    required this.maintenanceMode,
    required this.message,
    required this.eta,
  });

  factory MaintenanceSettings.defaultVal() {
    return const MaintenanceSettings(
      maintenanceMode: false,
      message: "System is undergoing scheduled maintenance.",
      eta: "2 hours",
    );
  }
}

class AppSettings {
  final String version;
  final bool forceUpdate;
  final int buildNumber;

  const AppSettings({
    required this.version,
    required this.forceUpdate,
    required this.buildNumber,
  });

  factory AppSettings.defaultVal() {
    return const AppSettings(
      version: "1.0.0",
      forceUpdate: false,
      buildNumber: 1,
    );
  }
}

class DashboardSettings {
  final String welcomeMessage;
  final List<dynamic> activeWidgets;
  const DashboardSettings({
    required this.welcomeMessage,
    required this.activeWidgets,
  });
  factory DashboardSettings.defaultVal() {
    return const DashboardSettings(
      welcomeMessage: "Welcome back, Admin",
      activeWidgets: [],
    );
  }
}
