import '../../../domain/entities/booking_timeline.dart';
import '../../../domain/entities/booking_gallery.dart';
import '../../../domain/entities/rebook_request.dart';
import '../../../core/utils/date_parser.dart';

class BookingTimelineModel extends BookingTimeline {
  const BookingTimelineModel({
    required super.id,
    required super.bookingId,
    required super.status,
    required super.updatedTime,
    super.notes,
  });

  factory BookingTimelineModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingTimelineModel(
      id: id,
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? '',
      updatedTime: DateParser.parse(json['updatedTime']),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'updatedTime': updatedTime.toIso8601String(),
      'notes': notes,
    };
  }
}

class BookingGalleryModel extends BookingGallery {
  const BookingGalleryModel({
    required super.id,
    required super.customerId,
    required super.bookingId,
    required super.mediaUrls,
    required super.createdAt,
  });

  factory BookingGalleryModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingGalleryModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingId': bookingId,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RebookRequestModel extends RebookRequest {
  const RebookRequestModel({
    required super.id,
    required super.customerId,
    required super.previousBookingId,
    required super.newDate,
    required super.status,
    required super.createdAt,
  });

  factory RebookRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return RebookRequestModel(
      id: id,
      customerId: json['customerId'] ?? '',
      previousBookingId: json['previousBookingId'] ?? '',
      newDate: DateParser.parse(json['newDate']),
      status: json['status'] ?? 'Pending',
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'previousBookingId': previousBookingId,
      'newDate': newDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
