import 'dart:math';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/config/app_routes.dart';
import '../../core/config/constants.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/usecases/create_quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/business_details_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
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

  // Generate Alphanumeric Public ID
  String _generatePublicId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
