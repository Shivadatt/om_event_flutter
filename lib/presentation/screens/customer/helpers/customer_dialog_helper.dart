import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_theme.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/quotation_controller.dart';

part 'parts/booking_dialogs.dart';
part 'parts/billing_dialogs.dart';

/// Helper class for launching Customer portal interactive dialog sheets and modals.
class CustomerDialogHelper {
  CustomerDialogHelper._();

  static void openLeadDialog(BuildContext context) {
    CustomerBookingDialogs.openLeadDialog(context);
  }

  static void openQuoteDialog(BuildContext context, QuotationController quoteController) {
    CustomerBookingDialogs.openQuoteDialog(context, quoteController);
  }

  static Future<void> launchWhatsApp(BuildContext context) async {
    await CustomerBillingDialogs.launchWhatsApp(context);
  }

  static Future<void> launchCall(BuildContext context) async {
    await CustomerBillingDialogs.launchCall(context);
  }
}
