import 'dart:math';
import 'package:get/get.dart';
import '../../core/config/app_routes.dart';
import '../../core/config/constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/quotation_pdf_generator.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/package_option.dart';
import '../../domain/usecases/create_quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import '../../core/services/booking_availability_service.dart';
import '../../core/services/fcm/notification_local_service.dart';
import 'customer_auth_controller.dart';
import 'cart_controller.dart';

part 'parts/quotation_pricing.dart';
part 'parts/quotation_actions.dart';

class QuotationController extends GetxController {
  final CreateQuotation createQuotationUsecase;
  final QuotationRepository quotationRepository;
  final CartController cartController;

  QuotationController({
    required this.createQuotationUsecase,
    required this.quotationRepository,
    required this.cartController,
  });

  final isGeneratingQuote = false.obs;
  final rxCreatedQuotation = Rxn<Quotation>();

  // Generate Standard Booking Reference ID (e.g. OM-20260923-481)
  String generateBookingReferenceId([DateTime? eventDate]) {
    final now = DateTime.now();
    final date = eventDate ?? now;
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final suffix = (Random().nextInt(900) + 100).toString();
    return 'OM-$year$month$day-$suffix';
  }

  String _generatePublicId([DateTime? eventDate]) => generateBookingReferenceId(eventDate);
}
