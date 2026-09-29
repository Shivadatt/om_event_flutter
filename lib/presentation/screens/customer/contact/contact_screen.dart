import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../core/utils/booking_communication_helper.dart';
import '../../../../core/utils/studio_locations_helper.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../helpers/customer_dialog_helper.dart';
import '../widgets/booking_tracker_dialog.dart';

class _WhatsAppOption {
  final String label;
  final String rawPhone;
  final String displayPhone;
  final bool isPrimary;

  const _WhatsAppOption({
    required this.label,
    required this.rawPhone,
    required this.displayPhone,
    this.isPrimary = false,
  });

  String get displayText {
    final suffix = isPrimary ? " (Primary)" : "";
    return "$label: $displayPhone$suffix";
  }
}

class _CustomPopupDivider extends PopupMenuEntry<Never> {
  const _CustomPopupDivider();
  @override
  double get height => 1;
  @override
  bool represents(dynamic value) => false;
  @override
  State<_CustomPopupDivider> createState() => _CustomPopupDividerState();
}

class _CustomPopupDividerState extends State<_CustomPopupDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFC9A77E).withValues(alpha: 0.25),
    );
  }
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _whatsAppCardKey = GlobalKey();
  final GlobalKey _appBarWhatsAppKey = GlobalKey();

  List<_WhatsAppOption> _resolveWhatsAppOptions() {
    final List<_WhatsAppOption> options = [];
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
            options.add(_WhatsAppOption(
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
      options.add(const _WhatsAppOption(
        label: "WhatsApp",
        rawPhone: "+91 93135 13156",
        displayPhone: "+91 93135 13156",
        isPrimary: true,
      ));
      options.add(const _WhatsAppOption(
        label: "Kadi (Medha)",
        rawPhone: "+91 95121 49944",
        displayPhone: "+91 95121 49944",
        isPrimary: false,
      ));
    } else if (options.length == 1) {
      if (options.first.rawPhone.contains('93135')) {
        options.add(const _WhatsAppOption(
          label: "Kadi (Medha)",
          rawPhone: "+91 95121 49944",
          displayPhone: "+91 95121 49944",
          isPrimary: false,
        ));
      } else {
        options.insert(
          0,
          const _WhatsAppOption(
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

  List<PopupMenuEntry<_WhatsAppOption>> _buildWhatsAppMenuItems(List<_WhatsAppOption> options) {
    final items = <PopupMenuEntry<_WhatsAppOption>>[];
    for (int i = 0; i < options.length; i++) {
      final opt = options[i];
      items.add(
        PopupMenuItem<_WhatsAppOption>(
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
        items.add(const _CustomPopupDivider());
      }
    }
    return items;
  }

  void _showWhatsAppMenu(BuildContext context, {GlobalKey? sourceKey}) async {
    final key = sourceKey ?? _whatsAppCardKey;
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    RelativeRect position;
    if (renderBox != null) {
      final cardRect = Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay),
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

    final options = _resolveWhatsAppOptions();
    final screenWidth = MediaQuery.of(context).size.width;

    final selected = await showMenu<_WhatsAppOption>(
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
      items: _buildWhatsAppMenuItems(options),
    );

    if (selected != null) {
      await BookingCommunicationHelper.openWhatsApp(
        phone: selected.rawPhone,
        message: BookingCommunicationHelper.generateGeneralInquiryMessage(),
      );
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedEventType = "Wedding";
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final List<String> _eventTypes = [
    "Wedding",
    "Reception & Sangeet",
    "Birthday Celebration",
    "Haldi & Mehndi",
    "Baby Shower / Naming Ceremony",
    "Anniversary Celebration",
    "Corporate & Gala Dinner",
    "Other Bespoke Setup",
  ];

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

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      final leadData = {
        'name': name,
        'phone': phone,
        'email': email,
        'source': 'Contact Page Form',
        'interest': _selectedEventType,
        'estimatedDate': _selectedDate?.toIso8601String() ?? '',
        'notes': message,
        'status': 'New',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Store in customer_leads collection
      await firestore.collection(AppCollections.customerLeads).add(leadData);

      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });

      // Clear fields
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _messageController.clear();
      _selectedDate = null;
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
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
  }

  void _showVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF091410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondaryAccent, width: 1.2),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  "OM EVENTS SHOWCASE",
                  style: GoogleFonts.italiana(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AppVideoPlayer(videoUrl: AppAssets.videoWeddingShowcase),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _safeLaunchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final target = (url.startsWith('http://') ||
              url.startsWith('https://') ||
              url.startsWith('tel:') ||
              url.startsWith('mailto:'))
          ? url
          : 'https://$url';
      await launchUrlString(target, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = AppColors.secondaryAccent;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF060D0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08120E).withValues(alpha: 0.98),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: goldColor, width: 1.2),
                color: const Color(0xFF0C1914),
              ),
              child: const Center(
                child: Text(
                  "OE",
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "OM EVENTS & DECORATORS",
              style: GoogleFonts.italiana(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            key: _appBarWhatsAppKey,
            onPressed: () => _showWhatsAppMenu(context, sourceKey: _appBarWhatsAppKey),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF4EBA7A)),
            label: Text(
              "WhatsApp",
              style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFF4EBA7A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: () => showBookingTrackerDialog(context),
            icon: const Icon(Icons.track_changes_rounded, size: 15, color: goldColor),
            label: Text(
              "Track",
              style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── 1. HERO SECTION (ATMOSPHERIC BACKGROUND & GOLD DIVIDER) ─────
            _buildHeroSection(context, goldColor, isDesktop),

            // ── 2. MAIN TWO-COLUMN CONTENT AREA ─────────────────────────────
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 16.0,
                    vertical: isDesktop ? 44.0 : 28.0,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (~56%): Studios + Direct Comm + Social
                            Expanded(
                              flex: 56,
                              child: _buildLeftContentColumn(context, goldColor, isDesktop),
                            ),
                            const SizedBox(width: 32),

                            // Right Column (~44%): Send Us an Inquiry Card
                            Expanded(
                              flex: 44,
                              child: _buildInquiryFormCard(context, goldColor),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftContentColumn(context, goldColor, isDesktop),
                            const SizedBox(height: 36),
                            _buildInquiryFormCard(context, goldColor),
                          ],
                        ),
                ),
              ),
            ),

            // ── 3. FULL PREMIUM FOOTER (IMAGE 2 & IMAGE 3 CANONICAL) ────────
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 16.0,
                    vertical: isDesktop ? 24.0 : 16.0,
                  ),
                  child: _buildPremiumFooter(context, goldColor, isDesktop, isTablet),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 1. HERO SECTION (ATMOSPHERIC PHOTO/VIDEO BACKGROUND & CENTER DIVIDER)
  // ============================================================================
  Widget _buildHeroSection(BuildContext context, Color goldColor, bool isDesktop) {
    return Container(
      width: double.infinity,
      height: isDesktop ? 300 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF091410),
      ),
      child: Stack(
        children: [
          // Background Atmospheric Photo
          Positioned.fill(
            child: Image.asset(
              AppImages.luxuryEveningDecor,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0C1914)),
            ),
          ),

          // Deep Dark Emerald Cinematic Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF060B09).withValues(alpha: 0.88),
                    const Color(0xFF060D0A).withValues(alpha: 0.65),
                    const Color(0xFF060D0A).withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),

          // Top-Right Play Video Button
          Positioned(
            top: 20,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showVideoDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1914).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldColor.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, size: 16, color: goldColor),
                      const SizedBox(width: 6),
                      Text(
                        "Play Video",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center Titles & Decorative Divider
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Eyebrow
                    Text(
                      "CONNECT WITH OUR CREATIVE TEAM",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.8,
                        color: goldColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Main Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Let's Craft Something ",
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 36 : 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          TextSpan(
                            text: "Extraordinary.",
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 36 : 27,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      "Whether you're planning a lavish wedding, an intimate milestone birthday, or require custom fabrication, our dual studios in Kadi and Thangadh are ready to assist you.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: isDesktop ? 12.5 : 11.5,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gold Decorative Divider: ─── ◇ ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 1.2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, goldColor.withValues(alpha: 0.6)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: goldColor,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 1.2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [goldColor.withValues(alpha: 0.6), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 2. LEFT CONTENT COLUMN (OUR STUDIOS & SHOWROOMS + DIRECT COMMUNICATION)
  // ============================================================================
  Widget _buildLeftContentColumn(BuildContext context, Color goldColor, bool isDesktop) {
    final businessPhone = BookingCommunicationHelper.getBusinessPhoneNumber();
    final businessEmail = BookingCommunicationHelper.getBusinessEmail();

    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final social = details.social;

      // Canonical Addresses
      final kadiAddress = "Medha (kadi-kalyanpura road), Kadi, Mehsana, Gujarat 382715";
      final thangadhAddress = "Thangadh(Surendranagar), Thangadh, Surendranagar, Gujarat 363530";

      // Canonical Instagram URLs
      final instagramKadiUrl = social.instagramKadi.trim().isNotEmpty
          ? social.instagramKadi.trim()
          : (social.instagram.trim().isNotEmpty ? social.instagram.trim() : "https://instagram.com/om_events_and_decorators");
      final instagramThangadhUrl = social.instagramThangadh.trim().isNotEmpty
          ? social.instagramThangadh.trim()
          : "https://instagram.com/om_events_decorators";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1 Header: OUR STUDIOS & SHOWROOMS
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.storefront_rounded, size: 16, color: goldColor),
              ),
              const SizedBox(width: 8),
              Text(
                "OUR STUDIOS & SHOWROOMS",
                style: GoogleFonts.italiana(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Visit our creative spaces to explore themes, setups and personalised consultations.",
            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white60),
          ),
          const SizedBox(height: 14),

          // Studio 1: Kadi (Medha)
          _buildStudioCard(
            title: "Kadi (Medha)",
            address: kadiAddress,
            imageAsset: AppImages.luxuryReception,
            goldColor: goldColor,
            isDesktop: isDesktop,
            onMapTap: () => StudioLocationsHelper.openInGoogleMaps(kadiAddress),
            onDirectionsTap: () => StudioLocationsHelper.getDirections(kadiAddress),
          ),
          const SizedBox(height: 14),

          // Studio 2: Thangadh
          _buildStudioCard(
            title: "Thangadh",
            address: thangadhAddress,
            imageAsset: AppImages.luxuryEveningDecor,
            goldColor: goldColor,
            isDesktop: isDesktop,
            onMapTap: () => StudioLocationsHelper.openInGoogleMaps(thangadhAddress),
            onDirectionsTap: () => StudioLocationsHelper.getDirections(thangadhAddress),
          ),
          const SizedBox(height: 24),

          // Section 2 Header: DIRECT COMMUNICATION
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.headset_mic_outlined, size: 16, color: goldColor),
              ),
              const SizedBox(width: 8),
              Text(
                "DIRECT COMMUNICATION",
                style: GoogleFonts.italiana(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Get in touch with us directly through your preferred channel.",
            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white60),
          ),
          const SizedBox(height: 14),

          // 4 Direct Communication Cards Grid
          _buildDirectCommunicationGrid(context, goldColor, businessPhone, businessEmail, isDesktop),
          const SizedBox(height: 24),

          // Section 3: FOLLOW OUR CELEBRATIONS (TWO INSTAGRAM LINKS)
          Text(
            "FOLLOW OUR CELEBRATIONS",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.2,
              color: goldColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInstagramPill(
                  label: "Instagram – Kadi",
                  url: instagramKadiUrl,
                  goldColor: goldColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInstagramPill(
                  label: "Instagram – Thangadh",
                  url: instagramThangadhUrl,
                  goldColor: goldColor,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // Studio Card with Image on Left & Action Buttons on Right
  Widget _buildStudioCard({
    required String title,
    required String address,
    required String imageAsset,
    required Color goldColor,
    required bool isDesktop,
    required VoidCallback onMapTap,
    required VoidCallback onDirectionsTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.25), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Image (36% width)
            Expanded(
              flex: 36,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF14241F),
                    child: Icon(Icons.storefront_rounded, color: goldColor, size: 28),
                  ),
                ),
              ),
            ),

            // Right Information (64% width)
            Expanded(
              flex: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header Row with Title and Action Arrow
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: goldColor, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.italiana(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Material(
                          color: goldColor.withValues(alpha: 0.15),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onDirectionsTap,
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 15,
                                color: AppColors.secondaryAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Full Address
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons Row (View Map + Directions)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: onMapTap,
                          icon: Icon(Icons.map_outlined, size: 12, color: goldColor),
                          label: Text(
                            "View Map",
                            style: AppTheme.sansBody(
                              fontSize: 10.5,
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: goldColor.withValues(alpha: 0.45)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: onDirectionsTap,
                          icon: const Icon(Icons.navigation_outlined, size: 12, color: Color(0xFF091210)),
                          label: Text(
                            "Directions",
                            style: AppTheme.sansBody(
                              fontSize: 10.5,
                              color: const Color(0xFF091210),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: const Color(0xFF091210),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4 Direct Communication Cards Grid
  Widget _buildDirectCommunicationGrid(
    BuildContext context,
    Color goldColor,
    String primaryPhone,
    String businessEmail,
    bool isDesktop,
  ) {
    final cards = [
      _buildCommCard(
        icon: Icons.phone_outlined,
        title: "Voice Calling",
        line1: "+91 93135 13156",
        line2: "+91 95121 49944",
        goldColor: goldColor,
        onTap: () => BookingCommunicationHelper.openCall("+91 93135 13156"),
      ),
      _buildCommCard(
        key: _whatsAppCardKey,
        icon: Icons.chat_bubble_outline_rounded,
        title: "WhatsApp Chat",
        line1: "Chat with our team for",
        line2: "instant assistance.",
        goldColor: const Color(0xFF4EBA7A),
        onTap: () => _showWhatsAppMenu(context, sourceKey: _whatsAppCardKey),
      ),
      _buildCommCard(
        icon: Icons.mail_outline_rounded,
        title: "Email Inquiries",
        line1: "omeventsanddecorators",
        line2: "@gmail.com",
        goldColor: goldColor,
        onTap: () => BookingCommunicationHelper.openEmail(),
      ),
      _buildCommCard(
        icon: Icons.map_outlined,
        title: "Service Area & Policy",
        line1: "Check delivery zones &",
        line2: "pin codes across Gujarat.",
        goldColor: goldColor,
        onTap: () => Get.toNamed(AppRoutes.serviceArea),
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: c,
                  ),
                ))
            .toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
        children: cards,
      );
    }
  }

  Widget _buildCommCard({
    Key? key,
    required IconData icon,
    required String title,
    required String line1,
    required String line2,
    required Color goldColor,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withValues(alpha: 0.22), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, size: 14, color: goldColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(fontSize: 9.5, color: Colors.white70),
                ),
                Text(
                  line2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(fontSize: 9.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramPill({
    required String label,
    required String url,
    required Color goldColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _safeLaunchUrl(url),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 15, color: goldColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_outward_rounded, size: 12, color: goldColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 3. RIGHT COLUMN: SEND US AN INQUIRY FORM CARD
  // ============================================================================
  Widget _buildInquiryFormCard(BuildContext context, Color goldColor) {
    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4EBA7A).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF4EBA7A)),
            ),
            const SizedBox(height: 20),
            Text(
              "MESSAGE SUBMITTED",
              style: GoogleFonts.italiana(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              "Your message has been submitted successfully.\nOur styling team will get back to you shortly.",
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => BookingCommunicationHelper.openWhatsApp(
                  message: BookingCommunicationHelper.generateGeneralInquiryMessage(),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                label: Text(
                  "CONTINUE ON WHATSAPP FOR INSTANT REPLY",
                  style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isSuccess = false),
              child: Text(
                "Send another message",
                style: AppTheme.sansBody(fontSize: 12, color: goldColor),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF091410),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withValues(alpha: 0.30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mail_outline_rounded, size: 16, color: goldColor),
                ),
                const SizedBox(width: 8),
                Text(
                  "SEND US AN INQUIRY",
                  style: GoogleFonts.italiana(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Share your event vision and our lead stylists will prepare a consultation.",
              style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white54),
            ),
            const SizedBox(height: 18),

            // 1. Full Name
            _buildFieldLabel("FULL NAME *", goldColor),
            TextFormField(
              controller: _nameController,
              style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
              validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your full name." : null,
              decoration: _inputDecoration("e.g. Priyaben Patel", Icons.person_outline, goldColor),
            ),
            const SizedBox(height: 12),

            // 2. Phone Number
            _buildFieldLabel("PHONE NUMBER * (10 DIGITS)", goldColor),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Please enter your phone number.";
                final clean = v.replaceAll(RegExp(r'\D'), '');
                if (clean.length < 10) return "Please enter a valid 10-digit phone number.";
                return null;
              },
              decoration: _inputDecoration("e.g. 9876543210", Icons.phone_outlined, goldColor),
            ),
            const SizedBox(height: 12),

            // 3. Email (Optional)
            _buildFieldLabel("EMAIL ADDRESS (OPTIONAL)", goldColor),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) return "Please enter a valid email address.";
                }
                return null;
              },
              decoration: _inputDecoration("e.g. priya@gmail.com", Icons.email_outlined, goldColor),
            ),
            const SizedBox(height: 12),

            // 4. Event Type Dropdown
            _buildFieldLabel("EVENT TYPE", goldColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF071410),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldColor.withValues(alpha: 0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEventType,
                  dropdownColor: const Color(0xFF0C1914),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedEventType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Estimated Celebration Date
            _buildFieldLabel("ESTIMATED CELEBRATION DATE", goldColor),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 14)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: goldColor,
                          surface: const Color(0xFF0C1914),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF071410),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: goldColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 16, color: goldColor),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                          : "Select estimated event date (optional)",
                      style: AppTheme.sansBody(
                        fontSize: 12.5,
                        color: _selectedDate != null ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. Message / Special Requirements
            _buildFieldLabel("MESSAGE / SPECIAL REQUIREMENTS *", goldColor),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 500,
              style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Please enter your message.";
                if (v.trim().length < 10) return "Message must be at least 10 characters.";
                return null;
              },
              decoration: InputDecoration(
                hintText: "Tell us about your venue, theme preferences, special requests...",
                hintStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                prefixIcon: const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
                  child: Icon(Icons.chat_outlined, size: 16, color: AppColors.secondaryAccent),
                ),
                filled: true,
                fillColor: const Color(0xFF071410),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor, width: 1.2),
                ),
                counterStyle: AppTheme.sansBody(fontSize: 9.5, color: Colors.white38),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button: SUBMIT INQUIRY →
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE5C378), Color(0xFFD4AF37), Color(0xFFC59D2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(23),
                    onTap: _isSubmitting ? null : _submitInquiry,
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF091210),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, size: 14, color: Color(0xFF091210)),
                                const SizedBox(width: 8),
                                Text(
                                  "SUBMIT INQUIRY",
                                  style: AppTheme.sansBody(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: const Color(0xFF091210),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, Color goldColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        text,
        style: AppTheme.sansBody(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: goldColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Color goldColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
      prefixIcon: Icon(icon, size: 16, color: goldColor.withValues(alpha: 0.75)),
      filled: true,
      fillColor: const Color(0xFF071410),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor, width: 1.2),
      ),
    );
  }

  // ============================================================================
  // 4. FULL PREMIUM FOOTER (IMAGE 2 & IMAGE 3 CANONICAL SPECIFICATION)
  // ============================================================================
  Widget _buildPremiumFooter(BuildContext context, Color goldColor, bool isDesktop, bool isTablet) {
    final originalDetails = BusinessDetailsService.to.rxDetails.value;
    final businessProfile = AppConfigService.to.rxBusinessProfile.value;

    // Resolve branch addresses dynamically from canonical settings/business_info
    final List<String> branchLines = [];
    if (originalDetails.branches.isNotEmpty) {
      for (final b in originalDetails.branches) {
        if (b.branchName.isNotEmpty) {
          final addr = b.fullAddress.isNotEmpty ? b.fullAddress.split(',').first.trim() : '';
          branchLines.add(addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName);
        }
      }
    } else if (businessProfile.officeBranches.isNotEmpty) {
      for (final b in businessProfile.officeBranches) {
        if (b.branchName.isNotEmpty) {
          final addr = b.address.isNotEmpty ? b.address.split(',').first.trim() : '';
          branchLines.add(addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName);
        }
      }
    }
    if (branchLines.isEmpty) {
      branchLines.add("Kadi (Medha) – Medha (kadi-kalyanpura road)");
      branchLines.add("Thangadh – Thangadh (Surendranagar)");
      branchLines.add("Gujarat, India 382715");
    } else if (branchLines.length == 2) {
      branchLines.add("Gujarat, India 382715");
    }

    // Resolve Phone numbers
    const primaryPhone = "+91 93135 13156";
    const secondaryPhone = "+91 95121 49944";
    const primaryEmail = "omeventsanddecorators@gmail.com";

    // Resolve location-specific Instagram URLs
    String instagramKadi = originalDetails.social.instagramKadi.trim().isNotEmpty
        ? originalDetails.social.instagramKadi.trim()
        : "https://instagram.com/om_events_and_decorators";
    String instagramThangadh = originalDetails.social.instagramThangadh.trim().isNotEmpty
        ? originalDetails.social.instagramThangadh.trim()
        : "https://instagram.com/om_events_decorators";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060907),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Content Columns
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 14.0, 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. BRAND BLOCK (flex: 30)
                          Expanded(
                            flex: 30,
                            child: _buildFooterBrandBlock(context, goldColor),
                          ),
                          const SizedBox(width: 16),

                          // 2. EXPLORE (flex: 12)
                          Expanded(
                            flex: 12,
                            child: _buildFooterExploreColumn(goldColor),
                          ),
                          const SizedBox(width: 12),

                          // 3. HELP (flex: 12)
                          Expanded(
                            flex: 12,
                            child: _buildFooterHelpColumn(context, goldColor),
                          ),
                          const SizedBox(width: 12),

                          // Divider 1
                          _buildVerticalDivider(goldColor),
                          const SizedBox(width: 12),

                          // 4. VISIT US (flex: 22)
                          Expanded(
                            flex: 22,
                            child: _buildFooterVisitUsColumn(branchLines, goldColor),
                          ),
                          const SizedBox(width: 12),

                          // Divider 2
                          _buildVerticalDivider(goldColor),
                          const SizedBox(width: 12),

                          // 5. GET IN TOUCH (flex: 24)
                          Expanded(
                            flex: 24,
                            child: _buildFooterGetInTouchColumn(
                              primaryPhone,
                              secondaryPhone,
                              primaryEmail,
                              instagramKadi,
                              instagramThangadh,
                              goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Integrated Decorative Arch Event Image
                  SizedBox(
                    width: 145,
                    child: _buildFooterDecorativeArch(goldColor),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterBrandBlock(context, goldColor),
                  const SizedBox(height: 18),
                  Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildFooterExploreColumn(goldColor)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildFooterHelpColumn(context, goldColor)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
                  const SizedBox(height: 18),
                  _buildFooterVisitUsColumn(branchLines, goldColor),
                  const SizedBox(height: 18),
                  Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
                  const SizedBox(height: 18),
                  _buildFooterGetInTouchColumn(
                    primaryPhone,
                    secondaryPhone,
                    primaryEmail,
                    instagramKadi,
                    instagramThangadh,
                    goldColor,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFooterBrandBlock(BuildContext context, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "LET'S CREATE SOMETHING EXTRAORDINARY",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.2,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Moments pass.\n",
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: "Beautiful ones echo.",
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "From intimate gatherings to grand celebrations, we turn your vision into unforgettable experiences.",
          style: AppTheme.sansBody(fontSize: 10, color: Colors.white60, height: 1.35),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => CustomerDialogHelper.openLeadDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor,
            foregroundColor: const Color(0xFF091210),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "START A CONVERSATION",
                style: AppTheme.sansBody(fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 12),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Social Media Icons
        Row(
          children: [
            _buildSmallSocialIcon(Icons.camera_alt_outlined, goldColor, () => _safeLaunchUrl("https://instagram.com/om_events_and_decorators")),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(Icons.facebook_outlined, goldColor, () => _safeLaunchUrl("https://facebook.com")),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(Icons.play_circle_outline_rounded, goldColor, () => _safeLaunchUrl("https://youtube.com")),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(Icons.chat_bubble_outline_rounded, goldColor, () => BookingCommunicationHelper.openWhatsApp(message: "Hello OM Events")),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallSocialIcon(IconData icon, Color goldColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 1),
          color: const Color(0xFF0C1914),
        ),
        child: Icon(icon, size: 12, color: goldColor),
      ),
    );
  }

  Widget _buildFooterExploreColumn(Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterHeader("EXPLORE", goldColor),
        const SizedBox(height: 8),
        _buildFooterLink("Collections", () => Get.offAllNamed(AppRoutes.home)),
        _buildFooterLink("Experiences", () => Get.offAllNamed(AppRoutes.home)),
        _buildFooterLink("Event Gallery", () => Get.toNamed(AppRoutes.gallery)),
        _buildFooterLink("Service Areas", () => Get.toNamed(AppRoutes.serviceArea)),
        _buildFooterLink("Booking Policy", () => Get.toNamed(AppRoutes.bookingPolicy)),
      ],
    );
  }

  Widget _buildFooterHelpColumn(BuildContext context, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterHeader("HELP", goldColor),
        const SizedBox(height: 8),
        _buildFooterLink("Cancellation Policy", () => Get.toNamed(AppRoutes.cancellationPolicy)),
        _buildFooterLink("Contact & Studios", () {}),
        _buildFooterLink("Stories", () => Get.offAllNamed(AppRoutes.home)),
        _buildFooterLink("Track Booking", () => showBookingTrackerDialog(context)),
        _buildFooterLink("FAQ", () => Get.offAllNamed(AppRoutes.home)),
      ],
    );
  }

  Widget _buildFooterVisitUsColumn(List<String> branches, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterHeader("VISIT US", goldColor),
        const SizedBox(height: 8),
        for (final b in branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    b,
                    style: AppTheme.sansBody(fontSize: 10, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooterGetInTouchColumn(
    String p1,
    String p2,
    String email,
    String instaKadi,
    String instaThangadh,
    Color goldColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterHeader("GET IN TOUCH", goldColor),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => BookingCommunicationHelper.openCall(p1),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(p1, style: AppTheme.sansBody(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => BookingCommunicationHelper.openCall(p2),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(p2, style: AppTheme.sansBody(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => BookingCommunicationHelper.openEmail(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => _safeLaunchUrl(instaKadi),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text("Instagram – Kadi ↗", style: AppTheme.sansBody(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => _safeLaunchUrl(instaThangadh),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text("Instagram – Thangadh ↗", style: AppTheme.sansBody(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterHeader(String title, Color goldColor) {
    return Text(
      title,
      style: AppTheme.sansBody(
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: goldColor,
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          label,
          style: AppTheme.sansBody(fontSize: 10, color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(Color goldColor) {
    return Container(
      width: 1,
      height: 140,
      color: goldColor.withValues(alpha: 0.15),
    );
  }

  Widget _buildFooterDecorativeArch(Color goldColor) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            child: Image.asset(
              AppImages.luxuryEveningDecor,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0C1914)),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF060907).withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 10,
          right: 10,
          child: Text(
            "Make\nEvery Moment\nExtra Special",
            style: GoogleFonts.italiana(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: goldColor,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
