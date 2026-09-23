import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/booking_availability_service.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/admin_booking_repository.dart';
import 'auth_controller.dart';

class AdminBookingController extends GetxController {
  final AdminBookingRepository _repository;

  AdminBookingController(this._repository);

  // Observable state
  final rxAllBookings = <Quotation>[].obs;
  final isLoading = false.obs;
  final isActionSubmitting = false.obs;

  // Filter & Search state
  final selectedStatusTab = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedDateFilter = 'All'.obs;
  final customFromDate = Rxn<DateTime>();
  final customToDate = Rxn<DateTime>();
  final selectedSort = 'Newest'.obs;

  // Selected Booking for Details / Dialogs
  final rxSelectedBooking = Rxn<Quotation>();

  // Calendar State
  final selectedCalendarMonth = DateTime.now().obs;
  final selectedCalendarDate = Rxn<DateTime>();

  // Operational KPIs
  final totalCount = 0.obs;
  final pendingCount = 0.obs;
  final acceptedCount = 0.obs;
  final confirmedCount = 0.obs;
  final upcomingEventsCount = 0.obs;
  final cancellationRequestsCount = 0.obs;
  final completedCount = 0.obs;

  StreamSubscription<List<Quotation>>? _bookingsSub;

  @override
  void onInit() {
    super.onInit();
    _bindStream();
    ever(rxAllBookings, (_) => _calculateKpis());
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
  }

  void _bindStream() {
    isLoading.value = true;
    _bookingsSub = _repository.streamAllBookings().listen((bookings) {
      rxAllBookings.assignAll(bookings);
      isLoading.value = false;
      _calculateKpis();
    }, onError: (err) {
      isLoading.value = false;
    });
  }

  bool _isCancellationPending(Quotation q) {
    if (q.status == QuotationStatus.cancelled) return false;
    // Check if cancellation request was made
    if (q.customerAction == 'cancellation_requested') return true;
    return false;
  }

  void _calculateKpis() {
    final all = rxAllBookings;
    totalCount.value = all.length;

    int pCount = 0;
    int aCount = 0;
    int cCount = 0;
    int upCount = 0;
    int cancCount = 0;
    int compCount = 0;

    final now = BookingAvailabilityService.nowIst();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    for (final b in all) {
      if (_isCancellationPending(b)) {
        cancCount++;
      }

      switch (b.status) {
        case QuotationStatus.published:
        case QuotationStatus.draft:
        case QuotationStatus.viewed:
        case QuotationStatus.republished:
          pCount++;
          break;
        case QuotationStatus.acceptedByClient:
          aCount++;
          break;
        case QuotationStatus.bookingConfirmed:
        case QuotationStatus.inProgress:
          cCount++;
          break;
        case QuotationStatus.completed:
          compCount++;
          break;
        case QuotationStatus.cancelled:
        case QuotationStatus.rejectedByClient:
        case QuotationStatus.expired:
        case QuotationStatus.archived:
        case QuotationStatus.revisionRequested:
        case QuotationStatus.underRevision:
          break;
      }

      // Check upcoming events
      final eventIst = BookingAvailabilityService.toIst(b.eventDate);
      final eventDayStart = DateTime.utc(eventIst.year, eventIst.month, eventIst.day);
      if (!eventDayStart.isBefore(todayStart) &&
          (b.status == QuotationStatus.bookingConfirmed ||
              b.status == QuotationStatus.acceptedByClient ||
              b.status == QuotationStatus.inProgress)) {
        upCount++;
      }
    }

    pendingCount.value = pCount;
    acceptedCount.value = aCount;
    confirmedCount.value = cCount;
    cancellationRequestsCount.value = cancCount;
    completedCount.value = compCount;
    upcomingEventsCount.value = upCount;
  }

  List<Quotation> get filteredBookings {
    List<Quotation> list = List.from(rxAllBookings);

    // 1. Status Filter
    final tab = selectedStatusTab.value;
    if (tab == 'Pending') {
      list = list.where((b) =>
          b.status == QuotationStatus.published ||
          b.status == QuotationStatus.draft ||
          b.status == QuotationStatus.viewed ||
          b.status == QuotationStatus.republished).toList();
    } else if (tab == 'Accepted') {
      list = list.where((b) => b.status == QuotationStatus.acceptedByClient).toList();
    } else if (tab == 'Confirmed') {
      list = list.where((b) =>
          b.status == QuotationStatus.bookingConfirmed ||
          b.status == QuotationStatus.inProgress).toList();
    } else if (tab == 'Cancellation Requests') {
      list = list.where(_isCancellationPending).toList();
    } else if (tab == 'Rejected') {
      list = list.where((b) => b.status == QuotationStatus.rejectedByClient).toList();
    } else if (tab == 'Completed') {
      list = list.where((b) => b.status == QuotationStatus.completed).toList();
    } else if (tab == 'Cancelled') {
      list = list.where((b) => b.status == QuotationStatus.cancelled).toList();
    }

    // 2. Search Query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((b) {
        return b.publicId.toLowerCase().contains(query) ||
            b.customerName.toLowerCase().contains(query) ||
            b.customerPhone.toLowerCase().contains(query) ||
            b.location.toLowerCase().contains(query) ||
            b.items.any((item) => item.name.toLowerCase().contains(query));
      }).toList();
    }

    // 3. Date Filter
    final dateFilter = selectedDateFilter.value;
    final nowIst = BookingAvailabilityService.nowIst();
    final today = DateTime.utc(nowIst.year, nowIst.month, nowIst.day);

    if (dateFilter == 'Today') {
      list = list.where((b) {
        final bDate = BookingAvailabilityService.toIst(b.eventDate);
        return bDate.year == today.year && bDate.month == today.month && bDate.day == today.day;
      }).toList();
    } else if (dateFilter == 'Tomorrow') {
      final tomorrow = today.add(const Duration(days: 1));
      list = list.where((b) {
        final bDate = BookingAvailabilityService.toIst(b.eventDate);
        return bDate.year == tomorrow.year && bDate.month == tomorrow.month && bDate.day == tomorrow.day;
      }).toList();
    } else if (dateFilter == 'This Week') {
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      list = list.where((b) {
        final bDate = BookingAvailabilityService.toIst(b.eventDate);
        return !bDate.isBefore(startOfWeek) && bDate.isBefore(endOfWeek);
      }).toList();
    } else if (dateFilter == 'This Month') {
      list = list.where((b) {
        final bDate = BookingAvailabilityService.toIst(b.eventDate);
        return bDate.year == today.year && bDate.month == today.month;
      }).toList();
    } else if (dateFilter == 'Custom' && customFromDate.value != null && customToDate.value != null) {
      final from = customFromDate.value!;
      final to = customToDate.value!.add(const Duration(days: 1));
      list = list.where((b) {
        final bDate = BookingAvailabilityService.toIst(b.eventDate);
        return !bDate.isBefore(from) && bDate.isBefore(to);
      }).toList();
    }

    // 4. Sorting
    final sort = selectedSort.value;
    if (sort == 'Newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sort == 'Oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sort == 'Event Date Asc') {
      list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    } else if (sort == 'Event Date Desc') {
      list.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    }

    return list;
  }

  List<Quotation> get recentBookings {
    final list = List<Quotation>.from(rxAllBookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(6).toList();
  }

  List<Quotation> get upcomingEvents {
    final now = BookingAvailabilityService.nowIst();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    final list = rxAllBookings.where((b) {
      final eventIst = BookingAvailabilityService.toIst(b.eventDate);
      final eventDayStart = DateTime.utc(eventIst.year, eventIst.month, eventIst.day);
      return !eventDayStart.isBefore(todayStart) &&
          (b.status == QuotationStatus.bookingConfirmed ||
              b.status == QuotationStatus.acceptedByClient ||
              b.status == QuotationStatus.inProgress);
    }).toList();

    list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return list.take(6).toList();
  }

  Map<String, Quotation> get bookingsByDateMap {
    final map = <String, Quotation>{};
    for (final b in rxAllBookings) {
      if (b.status == QuotationStatus.cancelled || b.status == QuotationStatus.rejectedByClient) {
        continue;
      }
      final key = BookingAvailabilityService.normalizeDateString(b.eventDate);
      map[key] = b;
    }
    return map;
  }

  String _getAdminIdentity() {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      final admin = auth.rxAdminRole.value;
      if (admin != null) {
        return admin.name.isNotEmpty ? admin.name : admin.email;
      }
    }
    return "Studio Admin";
  }

  String _getAdminUid() {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      return auth.rxAdminRole.value?.uid ?? 'admin';
    }
    return 'admin';
  }

  Future<void> acceptBooking(Quotation quote) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.acceptBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Booking Accepted", "Booking ${quote.publicId} is now accepted.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }

  Future<void> rejectBooking(Quotation quote, String reason, String? note) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.rejectBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
        reason: reason,
        note: note,
      );
      if (success) {
        Get.snackbar("Booking Rejected", "Booking ${quote.publicId} status updated.",
            backgroundColor: const Color(0xFF152621), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }

  Future<void> confirmBooking(Quotation quote) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.confirmBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Booking Confirmed! 🌟", "Booking ${quote.publicId} confirmed.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }

  Future<void> completeBooking(Quotation quote) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.completeBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Marked as Completed", "Booking ${quote.publicId} completed.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }

  Future<void> approveCancellation(Quotation quote) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.approveCancellation(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Cancellation Approved", "Booking ${quote.publicId} cancelled.",
            backgroundColor: const Color(0xFF152621), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }

  Future<void> rejectCancellation(Quotation quote, String reason) async {
    if (isActionSubmitting.value) return;
    try {
      isActionSubmitting.value = true;
      final success = await _repository.rejectCancellation(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
        reason: reason,
      );
      if (success) {
        Get.snackbar("Cancellation Rejected", "Cancellation for ${quote.publicId} rejected.",
            backgroundColor: const Color(0xFF152621), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
    } finally {
      isActionSubmitting.value = false;
    }
  }
}
