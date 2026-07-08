part of '../customer_dialog_helper.dart';

extension CustomerBillingDialogs on CustomerDialogHelper {
  /// Launch WhatsApp for active business numbers.
  static Future<void> launchWhatsApp(BuildContext context) async {
    final details = BusinessDetailsService.to.rxDetails.value;
    final activeNumbers =
        details.contacts.whatsapps.where((c) => c.isActive).toList();

    if (activeNumbers.isEmpty) {
      Get.snackbar("Error", "No active WhatsApp numbers configured.");
      return;
    }

    if (activeNumbers.length == 1) {
      final number = activeNumbers.first.value;
      const text = "Hello Om Events, I'd like to plan an event.";
      final uri = Uri.parse(
        "https://wa.me/$number?text=${Uri.encodeComponent(text)}",
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WHATSAPP US",
                    style: AppTheme.serifHeader(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeNumbers.map((cn) {
                    final labelSuffix = cn.isPrimary ? " (Primary)" : "";
                    return ListTile(
                      leading: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF2C9B5D),
                      ),
                      title: Text(
                        "WhatsApp ${cn.label}$labelSuffix",
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(cn.value),
                      onTap: () async {
                        Navigator.pop(context);
                        const text =
                            "Hello Om Events, I'd like to plan an event.";
                        final clean = cn.value.replaceAll(RegExp(r'\D'), '');
                        final targetVal = clean.length == 10 ? '91$clean' : clean;
                        final uri = Uri.parse(
                          "https://wa.me/$targetVal?text=${Uri.encodeComponent(text)}",
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  /// Launch phone call for active business numbers.
  static Future<void> launchCall(BuildContext context) async {
    final details = BusinessDetailsService.to.rxDetails.value;
    final activeNumbers =
        details.contacts.phones.where((c) => c.isActive).toList();

    if (activeNumbers.isEmpty) {
      Get.snackbar("Error", "No active contact numbers configured.");
      return;
    }

    if (activeNumbers.length == 1) {
      final uri = Uri.parse("tel:${activeNumbers.first.value}");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CALL US",
                    style: AppTheme.serifHeader(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeNumbers.map((cn) {
                    final labelSuffix = cn.isPrimary ? " (Primary)" : "";
                    return ListTile(
                      leading: const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFFC9A77E),
                      ),
                      title: Text(
                        cn.value,
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("${cn.label}$labelSuffix"),
                      onTap: () async {
                        Navigator.pop(context);
                        final uri = Uri.parse("tel:${cn.value}");
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
