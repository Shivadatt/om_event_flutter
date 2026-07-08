class NotificationPreferenceModel {
  final String uid;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool bookingEnabled;
  final bool paymentEnabled;
  final bool quotationEnabled;
  final bool reviewEnabled;
  final bool offerEnabled;
  final bool supportEnabled;
  final bool reminderEnabled;
  final bool marketingEnabled;
  final bool newsletterEnabled;
  final bool dndEnabled;
  final String quietHoursStart; // "HH:mm" format
  final String quietHoursEnd;   // "HH:mm" format
  final bool dailyDigestEnabled;

  const NotificationPreferenceModel({
    required this.uid,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.bookingEnabled,
    required this.paymentEnabled,
    required this.quotationEnabled,
    required this.reviewEnabled,
    required this.offerEnabled,
    required this.supportEnabled,
    required this.reminderEnabled,
    required this.marketingEnabled,
    required this.newsletterEnabled,
    required this.dndEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.dailyDigestEnabled,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json, String userId) {
    return NotificationPreferenceModel(
      uid: userId,
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      whatsappEnabled: json['whatsappEnabled'] ?? true,
      bookingEnabled: json['bookingEnabled'] ?? true,
      paymentEnabled: json['paymentEnabled'] ?? true,
      quotationEnabled: json['quotationEnabled'] ?? true,
      reviewEnabled: json['reviewEnabled'] ?? true,
      offerEnabled: json['offerEnabled'] ?? true,
      supportEnabled: json['supportEnabled'] ?? true,
      reminderEnabled: json['reminderEnabled'] ?? true,
      marketingEnabled: json['marketingEnabled'] ?? false,
      newsletterEnabled: json['newsletterEnabled'] ?? false,
      dndEnabled: json['dndEnabled'] ?? false,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
      dailyDigestEnabled: json['dailyDigestEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'whatsappEnabled': whatsappEnabled,
      'bookingEnabled': bookingEnabled,
      'paymentEnabled': paymentEnabled,
      'quotationEnabled': quotationEnabled,
      'reviewEnabled': reviewEnabled,
      'offerEnabled': offerEnabled,
      'supportEnabled': supportEnabled,
      'reminderEnabled': reminderEnabled,
      'marketingEnabled': marketingEnabled,
      'newsletterEnabled': newsletterEnabled,
      'dndEnabled': dndEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'dailyDigestEnabled': dailyDigestEnabled,
    };
  }
}
