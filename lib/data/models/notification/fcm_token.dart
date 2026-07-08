import '../../../core/utils/date_parser.dart';

class FcmTokenModel {
  final String userId;
  final String deviceToken;
  final String platform;
  final DateTime updatedAt;

  const FcmTokenModel({
    required this.userId,
    required this.deviceToken,
    required this.platform,
    required this.updatedAt,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      userId: json['userId'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      platform: json['platform'] ?? 'web',
      updatedAt: DateParser.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceToken': deviceToken,
      'platform': platform,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
