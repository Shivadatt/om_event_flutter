import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/review_model.dart';
import '../../data/models/booking_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  AdminRepository(this._firestore);

  // Reviews
  Future<List<ReviewModel>> getReviews() async {
    final snap = await _firestore.collection('reviews').orderBy('created_at', descending: true).get();
    return snap.docs.map((doc) => ReviewModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> saveReview(ReviewModel review, {required bool isEdit}) async {
    if (isEdit) {
      await _firestore.collection('reviews').doc(review.id).update(review.toJson());
    } else {
      await _firestore.collection('reviews').doc(review.id).set(review.toJson());
    }
  }

  Future<void> deleteReview(String id) async {
    await _firestore.collection('reviews').doc(id).delete();
  }

  // Bookings
  Future<List<BookingModel>> getBookings() async {
    final snap = await _firestore.collection('bookings').orderBy('created_at', descending: true).get();
    return snap.docs.map((doc) => BookingModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> saveBooking(BookingModel booking, {required bool isEdit}) async {
    if (isEdit) {
      await _firestore.collection('bookings').doc(booking.id).update(booking.toJson());
    } else {
      await _firestore.collection('bookings').doc(booking.id).set(booking.toJson());
    }
  }

  Future<void> deleteBooking(String id) async {
    await _firestore.collection('bookings').doc(id).delete();
  }

  // Settings
  Future<Map<String, dynamic>> getSettings() async {
    final doc = await _firestore.collection('settings').doc('business_info').get();
    return doc.data() ?? {};
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _firestore.collection('settings').doc('business_info').set(settings, SetOptions(merge: true));
  }

  // Profile Photo — updates only photo_url field in admin document
  Future<void> updateAdminPhotoUrl(String uid, String photoUrl) async {
    await _firestore.collection('admin').doc(uid).update({
      'photo_url': photoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Partial profile update — updates only editable profile fields
  Future<void> updateAdminProfileFields(String uid, Map<String, dynamic> fields) async {
    await _firestore.collection('admin').doc(uid).update({
      ...fields,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
