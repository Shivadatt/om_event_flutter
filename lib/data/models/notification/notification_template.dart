class NotificationTemplateModel {
  final String id;
  final String eventKey; // e.g., 'booking_confirmation'
  final String titleTemplate;
  final String bodyTemplate;
  final bool isPushEnabled;
  final bool isEmailEnabled;
  final bool isWhatsappEnabled;

  const NotificationTemplateModel({
    required this.id,
    required this.eventKey,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.isPushEnabled,
    required this.isEmailEnabled,
    required this.isWhatsappEnabled,
  });

  factory NotificationTemplateModel.fromJson(Map<String, dynamic> json, String documentId) {
    return NotificationTemplateModel(
      id: documentId,
      eventKey: json['eventKey'] ?? '',
      titleTemplate: json['titleTemplate'] ?? '',
      bodyTemplate: json['bodyTemplate'] ?? '',
      isPushEnabled: json['isPushEnabled'] ?? true,
      isEmailEnabled: json['isEmailEnabled'] ?? true,
      isWhatsappEnabled: json['isWhatsappEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventKey': eventKey,
      'titleTemplate': titleTemplate,
      'bodyTemplate': bodyTemplate,
      'isPushEnabled': isPushEnabled,
      'isEmailEnabled': isEmailEnabled,
      'isWhatsappEnabled': isWhatsappEnabled,
    };
  }
}
