import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/business_details_service.dart';
import '../../../../../core/utils/booking_communication_helper.dart';

import 'contact_popup_divider.dart';
import 'contact_whatsapp_option_model.dart';

class ContactWhatsAppMenu {
  static List<WhatsAppOption> resolveWhatsAppOptions() {
    final List<WhatsAppOption> options = [];
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final details = BusinessDetailsService.to.rxDetails.value;
        final activeWa = details.contacts.whatsapps.where((c) => c.isActive).toList();

        if (activeWa.isNotEmpty) {
          for (final wa in activeWa) {
            final isPrimary = wa.isPrimary ||
                wa.label.toLowerCase().contains('primary') ||
                wa.value.contains('93135');
            String cleanLabel = wa.label
                .replaceAll(RegExp(r'\s*WhatsApp\s*$', caseSensitive: false), '')
                .trim();
            if (cleanLabel.isEmpty) {
              cleanLabel = isPrimary ? "WhatsApp" : "Kadi (Medha)";
            }
            final display = BookingCommunicationHelper.formatDisplayPhone(wa.value);
            options.add(WhatsAppOption(
              label: cleanLabel,
              rawPhone: wa.value,
              displayPhone: display,
              isPrimary: isPrimary,
            ));
          }
        }
      }
    } catch (_) {}

    // Ensure both canonical business numbers requested exist
    if (options.isEmpty) {
      options.add(const WhatsAppOption(
        label: "WhatsApp",
        rawPhone: "+91 93135 13156",
        displayPhone: "+91 93135 13156",
        isPrimary: true,
      ));
      options.add(const WhatsAppOption(
        label: "Kadi (Medha)",
        rawPhone: "+91 95121 49944",
        displayPhone: "+91 95121 49944",
        isPrimary: false,
      ));
    } else if (options.length == 1) {
      if (options.first.rawPhone.contains('93135')) {
        options.add(const WhatsAppOption(
          label: "Kadi (Medha)",
          rawPhone: "+91 95121 49944",
          displayPhone: "+91 95121 49944",
          isPrimary: false,
        ));
      } else {
        options.insert(
          0,
          const WhatsAppOption(
            label: "WhatsApp",
            rawPhone: "+91 93135 13156",
            displayPhone: "+91 93135 13156",
            isPrimary: true,
          ),
        );
      }
    }

    return options;
  }

  static List<PopupMenuEntry<WhatsAppOption>> buildWhatsAppMenuItems(
    List<WhatsAppOption> options,
  ) {
    final items = <PopupMenuEntry<WhatsAppOption>>[];
    for (int i = 0; i < options.length; i++) {
      final opt = options[i];
      items.add(
        PopupMenuItem<WhatsAppOption>(
          value: opt,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(
                Icons.chat,
                color: Color(0xFF2C9B5D),
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  opt.displayText,
                  style: AppTheme.sansBody(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < options.length - 1) {
        items.add(const CustomPopupDivider());
      }
    }
    return items;
  }

  static Future<void> showWhatsAppMenu(
    BuildContext context, {
    required GlobalKey sourceKey,
  }) async {
    final RenderBox? renderBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    RelativeRect position;
    if (renderBox != null) {
      final cardRect = Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      );
      final isNearTop = cardRect.top < 160;
      final topOffset = isNearTop ? cardRect.bottom + 6 : cardRect.top - 110;

      position = RelativeRect.fromRect(
        Rect.fromLTWH(cardRect.left, topOffset, cardRect.width, 100),
        Offset.zero & overlay.size,
      );
    } else {
      final size = MediaQuery.of(context).size;
      position = RelativeRect.fromLTRB(
        size.width / 2 - 150,
        size.height / 2 - 50,
        size.width / 2 + 150,
        size.height / 2 + 50,
      );
    }

    final options = resolveWhatsAppOptions();
    final screenWidth = MediaQuery.of(context).size.width;

    final selected = await showMenu<WhatsAppOption>(
      context: context,
      position: position,
      elevation: 16,
      color: const Color(0xFF0D1915),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFC9A77E), width: 1.2),
      ),
      constraints: BoxConstraints(
        minWidth: math.min(300.0, screenWidth - 24.0),
        maxWidth: math.min(360.0, screenWidth - 24.0),
      ),
      items: buildWhatsAppMenuItems(options),
    );

    if (selected != null) {
      await BookingCommunicationHelper.openWhatsApp(
        phone: selected.rawPhone,
        message: BookingCommunicationHelper.generateGeneralInquiryMessage(),
      );
    }
  }
}
