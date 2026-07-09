import '../../../domain/entities/customer_activity.dart';
import '../../../domain/entities/customer_wishlist.dart';
import '../../../core/utils/date_parser.dart';

class CustomerActivityModel extends CustomerActivity {
  const CustomerActivityModel({
    required super.id,
    required super.customerId,
    required super.status,
    required super.updatedAt,
    super.details,
  });

  factory CustomerActivityModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerActivityModel(
      id: id,
      customerId: json['customerId'] ?? '',
      status: json['status'] ?? 'Registered',
      updatedAt: DateParser.parse(json['updatedAt']),
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
      'details': details,
    };
  }
}

class CustomerWishlistModel extends CustomerWishlist {
  const CustomerWishlistModel({
    required super.id,
    required super.customerId,
    required super.experienceId,
    required super.addedAt,
  });

  factory CustomerWishlistModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerWishlistModel(
      id: id,
      customerId: json['customerId'] ?? '',
      experienceId: json['experienceId'] ?? '',
      addedAt: DateParser.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'experienceId': experienceId,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
