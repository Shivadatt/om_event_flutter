import 'package:firebase_auth/firebase_auth.dart';
import '../errors/failures.dart';

/// Centralized mapper that transforms internal exceptions, Firestore errors,
/// and network failures into safe, customer-friendly messages.
/// Under NO circumstance should raw backend codes, stack traces, or collection
/// names be returned to customer-facing UI widgets.
class AppErrorMapper {
  AppErrorMapper._();

  /// Maps errors encountered during date availability verification.
  static String mapAvailabilityError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "Unable to check availability right now. Please try again.";
        case 'unavailable':
          return "We're unable to reach the service right now. Please try again.";
        case 'deadline-exceeded':
          return "Availability check timed out. Please check your connection and try again.";
        case 'failed-precondition':
        case 'invalid-argument':
        case 'not-found':
          return "Unable to verify date availability right now. Please try again.";
        default:
          return "Unable to verify date availability right now. Please check your connection and try again.";
      }
    }

    if (error is Failure) {
      return error.message;
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('network') ||
        errStr.contains('socket') ||
        errStr.contains('connection') ||
        errStr.contains('offline') ||
        errStr.contains('failed to fetch')) {
      return "Please check your internet connection and try again.";
    }

    return "Something went wrong while checking availability. Please try again.";
  }

  /// Maps errors encountered during booking submission or checkout.
  static String mapBookingError(dynamic error) {
    if (error is ServerFailure) {
      // If it contains raw exception or diagnostic noise, sanitize it
      final msg = error.message;
      if (msg.contains('cloud_firestore') ||
          msg.contains('permission-denied') ||
          msg.contains('Exception:')) {
        return "Unable to process booking at this time. Please try again.";
      }
      return msg;
    }

    if (error is Failure) {
      return error.message;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "Unable to submit booking right now. Please sign in again and retry.";
        case 'unavailable':
          return "The booking service is temporarily unavailable. Please try again shortly.";
        case 'deadline-exceeded':
          return "Booking request timed out. Please check your connection.";
        default:
          return "Something went wrong while processing your booking. Please try again.";
      }
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('network') ||
        errStr.contains('socket') ||
        errStr.contains('connection') ||
        errStr.contains('offline')) {
      return "Network connection issue. Please check your internet connection and try again.";
    }

    return "Unable to complete booking. Please try again or reach out to our concierge.";
  }

  /// Maps general customer action errors (e.g. updating profile, inquiries, reviews).
  static String mapCustomerError(
    dynamic error, {
    String fallback = "Action could not be completed. Please try again.",
  }) {
    if (error is Failure) {
      return error.message;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "You do not have permission to perform this action. Please sign in again.";
        case 'unavailable':
          return "Service temporarily unavailable. Please try again in a few moments.";
        case 'deadline-exceeded':
          return "The request timed out. Please check your connection.";
        default:
          return fallback;
      }
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('network') ||
        errStr.contains('socket') ||
        errStr.contains('connection')) {
      return "Network connection issue. Please verify your connection.";
    }

    return fallback;
  }

  /// Maps general errors to safe, friendly messages.
  static String mapGeneralError(
    dynamic error, {
    String fallback = "Something went wrong. Please try again.",
  }) {
    return mapCustomerError(error, fallback: fallback);
  }

  /// Maps authentication errors to safe, friendly messages.
  static String mapAuthError(
    dynamic error, {
    String fallback = "Authentication failed. Please try again.",
  }) {
    if (error is Failure) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return "Invalid email or password. Please check your credentials.";
        case 'email-already-in-use':
          return "An account already exists with this email address.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        case 'weak-password':
          return "Password should be at least 6 characters.";
        case 'user-disabled':
          return "This account has been disabled. Please contact support.";
        case 'invalid-verification-code':
          return "Invalid verification code. Please check the OTP.";
        case 'session-expired':
          return "Verification session has expired. Please request a new code.";
        case 'too-many-requests':
          return "Too many attempts. Please try again later.";
        default:
          return fallback;
      }
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('network') || errStr.contains('connection')) {
      return "Network issue. Please check your internet connection and try again.";
    }

    return fallback;
  }
}

