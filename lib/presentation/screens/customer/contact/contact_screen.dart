import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/booking_tracker_dialog.dart';
import 'widgets/contact_app_bar.dart';
import 'widgets/contact_content_layout.dart';
import 'widgets/contact_hero_section.dart';
import 'widgets/contact_inquiry_helper.dart';
import 'widgets/contact_inquiry_section.dart';
import 'widgets/contact_left_column.dart';
import 'widgets/contact_premium_footer.dart';
import 'widgets/contact_whatsapp_options.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _whatsAppCardKey = GlobalKey();
  final GlobalKey _appBarWhatsAppKey = GlobalKey();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedEventType = "Wedding";
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ContactInquiryHelper.submitLead(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        interest: _selectedEventType,
        estimatedDate: _selectedDate,
        notes: _messageController.text.trim(),
      );
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _messageController.clear();
      _selectedDate = null;
    } catch (_) {
      setState(() => _isSubmitting = false);
      if (mounted) ContactInquiryHelper.showErrorSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = AppColors.secondaryAccent;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isLaptop = screenWidth >= 1024 && screenWidth < 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    final hPad = isDesktop
        ? 32.0
        : (isLaptop ? 20.0 : (isTablet ? 16.0 : (screenWidth <= 360 ? 8.0 : 12.0)));
    final vPad = isDesktop ? 40.0 : (isTablet ? 28.0 : 20.0);

    return Scaffold(
      backgroundColor: const Color(0xFF060D0A),
      appBar: ContactAppBar(
        goldColor: goldColor,
        isMobile: isMobile,
        isDesktop: isDesktop,
        screenWidth: screenWidth,
        appBarWhatsAppKey: _appBarWhatsAppKey,
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        },
        onWhatsAppPressed: () => ContactWhatsAppMenu.showWhatsAppMenu(
          context,
          sourceKey: _appBarWhatsAppKey,
        ),
        onTrackPressed: () => showBookingTrackerDialog(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ContactHeroSection(
              goldColor: goldColor,
              isDesktop: isDesktop,
              isTablet: isTablet,
              isMobile: isMobile,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  child: ContactContentLayout(
                    useTwoColumn: screenWidth >= 740,
                    isDesktop: isDesktop,
                    isLaptop: isLaptop,
                    leftContent: ContactLeftColumn(
                      goldColor: goldColor,
                      isDesktop: isDesktop,
                      isLaptop: isLaptop,
                      isTablet: isTablet,
                      isMobile: isMobile,
                      whatsAppCardKey: _whatsAppCardKey,
                      onWhatsAppTap: () => ContactWhatsAppMenu.showWhatsAppMenu(
                        context,
                        sourceKey: _whatsAppCardKey,
                      ),
                    ),
                    rightContent: ContactInquirySection(
                      isSuccess: _isSuccess,
                      onReset: () => setState(() => _isSuccess = false),
                      formKey: _formKey,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                      messageController: _messageController,
                      selectedEventType: _selectedEventType,
                      eventTypes: ContactInquiryHelper.eventTypes,
                      onEventTypeChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedEventType = val);
                        }
                      },
                      selectedDate: _selectedDate,
                      onSelectDate: () async {
                        final d = await ContactInquiryHelper.pickDate(
                          context, _selectedDate, goldColor,
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      isSubmitting: _isSubmitting,
                      onSubmit: _submitInquiry,
                      goldColor: goldColor,
                      isMobile: isMobile,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: isDesktop ? 24.0 : 16.0,
                  ),
                  child: ContactPremiumFooter(
                    goldColor: goldColor,
                    isDesktop: isDesktop,
                    isLaptop: isLaptop,
                    isTablet: isTablet,
                    isMobile: isMobile,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
