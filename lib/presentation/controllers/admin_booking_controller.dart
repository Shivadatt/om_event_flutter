import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/services/booking_availability_service.dart';
import '../../core/utils/booking_status_helper.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/admin_booking_repository.dart';
import 'auth_controller.dart';

enum BookingViewMode {
  list,
  grid,
}

class AdminBookingController extends GetxController {
  final AdminBookingRepository _repository;

  AdminBookingController(this._repository);

  // Observable state
  final rxAllBookings = <Quotation>[].obs;
  final isLoading = false.obs;
  final isActionSubmitting = false.obs;
  final submittingAction = ''.obs;

  // View mode (List vs Grid)
  final viewMode = BookingViewMode.list.obs;

  // Filter & Search state
  final selectedStatusTab = 'All'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
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
  final rejectedCount = 0.obs;
  final cancelledCount = 0.obs;

  StreamSubscription<List<Quotation>>? _bookingsSub;

  @override
  void onInit() {
    super.onInit();
    _bindStream();
    ever(rxAllBookings, (_) => _calculateKpis());
  }

  void updateSearch(String val) {
    searchQuery.value = val;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
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
    int rCount = 0;
    int cancStatusCount = 0;

    final now = BookingAvailabilityService.nowIst();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    for (final b in all) {
      if (_isCancellationPending(b)) {
        cancCount++;
      }

      final eff = BookingStatusHelper.getEffectiveQuotationStatus(b);

      switch (eff) {
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
          cancStatusCount++;
          break;
        case QuotationStatus.rejectedByClient:
          rCount++;
          break;
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
          (eff == QuotationStatus.bookingConfirmed ||
              eff == QuotationStatus.acceptedByClient ||
              eff == QuotationStatus.inProgress)) {
        upCount++;
      }
    }

    pendingCount.value = pCount;
    acceptedCount.value = aCount;
    confirmedCount.value = cCount;
    cancellationRequestsCount.value = cancCount;
    completedCount.value = compCount;
    upcomingEventsCount.value = upCount;
    rejectedCount.value = rCount;
    cancelledCount.value = cancStatusCount;
  }

  List<Quotation> get filteredBookings {
    List<Quotation> list = List.from(rxAllBookings);

    // 1. Status Filter
    final tab = selectedStatusTab.value;
    if (tab == 'Pending') {
      list = list.where((b) {
        final eff = BookingStatusHelper.getEffectiveQuotationStatus(b);
        return eff == QuotationStatus.published ||
            eff == QuotationStatus.draft ||
            eff == QuotationStatus.viewed ||
            eff == QuotationStatus.republished;
      }).toList();
    } else if (tab == 'Accepted') {
      list = list.where((b) =>
          BookingStatusHelper.getEffectiveQuotationStatus(b) == QuotationStatus.acceptedByClient).toList();
    } else if (tab == 'Confirmed') {
      list = list.where((b) {
        final eff = BookingStatusHelper.getEffectiveQuotationStatus(b);
        return eff == QuotationStatus.bookingConfirmed ||
            eff == QuotationStatus.inProgress;
      }).toList();
    } else if (tab == 'Cancellation Requests') {
      list = list.where(_isCancellationPending).toList();
    } else if (tab == 'Rejected') {
      list = list.where((b) =>
          BookingStatusHelper.getEffectiveQuotationStatus(b) == QuotationStatus.rejectedByClient).toList();
    } else if (tab == 'Completed') {
      list = list.where((b) =>
          BookingStatusHelper.getEffectiveQuotationStatus(b) == QuotationStatus.completed).toList();
    } else if (tab == 'Cancelled') {
      list = list.where((b) =>
          BookingStatusHelper.getEffectiveQuotationStatus(b) == QuotationStatus.cancelled).toList();
    }

    // 2. Date Filter
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

    // 3. Search Query Filter (Realtime, Case-Insensitive, Trimmed)
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((b) {
        final idMatch = b.id.toLowerCase().contains(query) ||
            b.publicId.toLowerCase().contains(query);
        final nameMatch = b.customerName.toLowerCase().contains(query);
        final rawPhone = b.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
        final queryDigits = query.replaceAll(RegExp(r'[^0-9]'), '');
        final phoneMatch = (queryDigits.isNotEmpty && rawPhone.contains(queryDigits)) ||
            b.customerPhone.toLowerCase().contains(query);
        final locationMatch = b.location.toLowerCase().contains(query);
        final serviceMatch = b.items.any((item) =>
            item.name.toLowerCase().contains(query) ||
            item.theme.toLowerCase().contains(query) ||
            item.experienceId.toLowerCase().contains(query) ||
            item.notes.toLowerCase().contains(query)) ||
            (b.bookingDetails ?? '').toLowerCase().contains(query);
        final notesMatch = b.notes.toLowerCase().contains(query);

        return idMatch || nameMatch || phoneMatch || locationMatch || serviceMatch || notesMatch;
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
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null && currentUid.isNotEmpty) {
      return currentUid;
    }
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      return auth.rxAdminRole.value?.uid ?? 'admin';
    }
    return 'admin';
  }

  String _extractErrorMessage(dynamic e) {
    if (e == null) return "An unexpected error occurred.";
    try {
      final dynamic boxed = (e as dynamic).error;
      if (boxed != null) {
        final bStr = boxed.toString();
        if (bStr.isNotEmpty && !bStr.contains("converted Future")) {
          return bStr.replaceAll("Exception: ", "").replaceAll("Error: ", "");
        }
        final dynamic boxedMsg = (boxed as dynamic).message;
        if (boxedMsg != null && boxedMsg.toString().isNotEmpty) {
          return boxedMsg.toString();
        }
      }
    } catch (_) {}
    try {
      final dynamic msg = (e as dynamic).message;
      if (msg != null && msg.toString().isNotEmpty) {
        return msg.toString();
      }
    } catch (_) {}
    final raw = e.toString();
    if (raw.contains("converted Future")) {
      return "Unable to complete request. Please verify permissions or network connection.";
    }
    return raw.replaceAll("Exception: ", "").replaceAll("Error: ", "");
  }

  Future<bool> acceptBooking(Quotation quote) async {
    if (isActionSubmitting.value) return false;
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'accept';
      final success = await _repository.acceptBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Booking Accepted", "Booking ${quote.publicId} is now accepted.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
    }
  }

  Future<bool> rejectBooking(Quotation quote, String reason, String? note) async {
    if (isActionSubmitting.value) return false;
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'reject';
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
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
    }
  }

  Future<bool> confirmBooking(Quotation quote) async {
    if (isActionSubmitting.value) return false;
    final currentAuthUser = FirebaseAuth.instance.currentUser;
    debugPrint("==================================================");
    debugPrint("[CONFIRM_DEBUG] >>> confirmBooking triggered for quote: ${quote.publicId} (${quote.id})");
    debugPrint("[CONFIRM_DEBUG] Auth User UID: ${currentAuthUser?.uid}");
    debugPrint("[CONFIRM_DEBUG] Auth User Email: ${currentAuthUser?.email}");
    debugPrint("[CONFIRM_DEBUG] Auth Is Anonymous: ${currentAuthUser?.isAnonymous}");
    debugPrint("[CONFIRM_DEBUG] Admin UID: ${_getAdminUid()}");
    debugPrint("[CONFIRM_DEBUG] Admin Name: ${_getAdminIdentity()}");
    debugPrint("[CONFIRM_DEBUG] Quote Customer ID: ${quote.customerId}");
    debugPrint("[CONFIRM_DEBUG] Quote Event Date: ${quote.eventDate}");
    debugPrint("[CONFIRM_DEBUG] Current Status: ${quote.status.nameStr}");
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'confirm';
      final success = await _repository.confirmBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      debugPrint("[CONFIRM_DEBUG] Repository confirmation SUCCESS: $success");
      if (success) {
        Get.snackbar("Booking Confirmed! 🌟", "Booking ${quote.publicId} confirmed.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint("[CONFIRM_DEBUG] !!! EXCEPTION during confirmBooking: $e");
      debugPrint("[CONFIRM_DEBUG] Stack trace: $stack");
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
      debugPrint("==================================================");
    }
  }

  Future<bool> completeBooking(Quotation quote) async {
    if (isActionSubmitting.value) return false;
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'complete';
      final success = await _repository.completeBooking(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Marked as Completed", "Booking ${quote.publicId} completed.",
            backgroundColor: const Color(0xFF152621), colorText: const Color(0xFFD4AF37));
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
    }
  }

  Future<bool> approveCancellation(Quotation quote) async {
    if (isActionSubmitting.value) return false;
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'cancel_approve';
      final success = await _repository.approveCancellation(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
      );
      if (success) {
        Get.snackbar("Cancellation Approved", "Booking ${quote.publicId} cancelled.",
            backgroundColor: const Color(0xFF152621), colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
    }
  }

  Future<bool> rejectCancellation(Quotation quote, String reason) async {
    if (isActionSubmitting.value) return false;
    try {
      isActionSubmitting.value = true;
      submittingAction.value = 'cancel_reject';
      final success = await _repository.rejectCancellation(
        bookingId: quote.id,
        adminId: _getAdminUid(),
        adminName: _getAdminIdentity(),
        reason: reason,
      );
      if (success) {
        Get.snackbar("Cancellation Rejected", "Cancellation for ${quote.publicId} rejected.",
            backgroundColor: const Color(0xFF152621), colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", _extractErrorMessage(e),
          backgroundColor: const Color(0xFF2A1515), colorText: Colors.redAccent);
      return false;
    } finally {
      isActionSubmitting.value = false;
      submittingAction.value = '';
    }
  }
}
