import '../../../domain/entities/offer.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/entities/coordinator.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/entities/staff_log.dart';
import '../../../domain/entities/expense_item.dart';
import '../../../core/utils/date_parser.dart';

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.isActive,
    required super.priority,
    required super.expiryDate,
    required super.branch,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json, String id) {
    return OfferModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      expiryDate: DateParser.parse(json['expiryDate']),
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'priority': priority,
      'expiryDate': expiryDate.toIso8601String(),
      'branch': branch,
    };
  }
}

class CouponModel extends Coupon {
  const CouponModel({
    required super.id,
    required super.code,
    required super.discount,
    required super.validity,
    required super.usageLimit,
    required super.branch,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json, String id) {
    return CouponModel(
      id: id,
      code: json['code'] ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      validity: DateParser.parse(json['validity']),
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 0,
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount': discount,
      'validity': validity.toIso8601String(),
      'usageLimit': usageLimit,
      'branch': branch,
    };
  }
}

class CoordinatorModel extends Coordinator {
  const CoordinatorModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.photoUrl,
    required super.isActive,
  });

  factory CoordinatorModel.fromJson(Map<String, dynamic> json, String id) {
    return CoordinatorModel(
      id: id,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'isActive': isActive,
    };
  }
}

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.name,
    required super.stock,
    required super.lowStockThreshold,
    required super.supplierName,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json, String id) {
    return InventoryItemModel(
      id: id,
      name: json['name'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      supplierName: json['supplierName'] ?? 'General Supplier',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'supplierName': supplierName,
    };
  }
}

class StaffLogModel extends StaffLog {
  const StaffLogModel({
    required super.id,
    required super.name,
    required super.attendance,
    required super.taskDescription,
    required super.date,
  });

  factory StaffLogModel.fromJson(Map<String, dynamic> json, String id) {
    return StaffLogModel(
      id: id,
      name: json['name'] ?? '',
      attendance: json['attendance'] ?? 'Present',
      taskDescription: json['taskDescription'] ?? '',
      date: DateParser.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attendance': attendance,
      'taskDescription': taskDescription,
      'date': date.toIso8601String(),
    };
  }
}

class ExpenseItemModel extends ExpenseItem {
  const ExpenseItemModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.date,
    required super.bookingId,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpenseItemModel(
      id: id,
      category: json['category'] ?? 'Decorations',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateParser.parse(json['date']),
      bookingId: json['bookingId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'bookingId': bookingId,
    };
  }
}
