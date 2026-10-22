import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_collections.dart';

class ContactInquiryHelper {
  static const List<String> eventTypes = [
    "Wedding",
    "Reception & Sangeet",
    "Birthday Celebration",
    "Haldi & Mehndi",
    "Baby Shower / Naming Ceremony",
    "Anniversary Celebration",
    "Corporate & Gala Dinner",
    "Other Bespoke Setup",
  ];

  static Future<bool> submitLead({
    required String name,
    required String phone,
    required String email,
    required String interest,
    DateTime? estimatedDate,
    required String notes,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    await firestore.collection(AppCollections.customerLeads).add({
      'name': name,
      'phone': phone,
      'email': email,
      'source': 'Contact Page Form',
      'interest': interest,
      'estimatedDate': estimatedDate?.toIso8601String() ?? '',
      'notes': notes,
      'status': 'New',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return true;
  }

  static void showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Could not send message. Please reach us directly on WhatsApp or Call.",
          style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC2410C),
      ),
    );
  }

  static Future<DateTime?> pickDate(
    BuildContext context,
    DateTime? current,
    Color goldColor,
  ) {
    return showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: goldColor,
            surface: const Color(0xFF0C1914),
          ),
        ),
        child: child!,
      ),
    );
  }
}
