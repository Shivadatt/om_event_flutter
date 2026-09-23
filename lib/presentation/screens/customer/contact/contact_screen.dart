import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../core/utils/booking_communication_helper.dart';
import '../../../../core/utils/studio_locations_helper.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    const goldColor = AppColors.secondaryAccent;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1815),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "OM EVENTS & DECORATORS",
          style: GoogleFonts.italiana(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => BookingCommunicationHelper.openWhatsApp(
              message: BookingCommunicationHelper.generateGeneralInquiryMessage(),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF4EBA7A)),
            label: Text(
              "WhatsApp",
              style: AppTheme.sansBody(fontSize: 12, color: const Color(0xFF4EBA7A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            _buildHeroHeader(goldColor, isDesktop),

            // Content Body
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.0 : 20.0,
                  vertical: isDesktop ? 60.0 : 36.0,
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildContactInfoPanel(context, goldColor)),
                          const SizedBox(width: 48),
                          Expanded(flex: 7, child: _buildFormCard(context, goldColor)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildContactInfoPanel(context, goldColor),
                          const SizedBox(height: 36),
                          _buildFormCard(context, goldColor),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(Color goldColor, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 60 : 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF12231E),
        border: Border(
          bottom: BorderSide(color: goldColor.withValues(alpha: 0.15)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                "CONNECT WITH OUR CREATIVE TEAM",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: goldColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Let's Craft Something Extraordinary.",
                textAlign: TextAlign.center,
                style: GoogleFonts.italiana(
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Whether you're planning a lavish wedding, an intimate milestone birthday, or require custom fabrication, our dual studios in Kadi and Thangadh are ready to assist you.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoPanel(BuildContext context, Color goldColor) {
    final studios = StudioLocationsHelper.getPublicStudios();
    final businessPhone = BookingCommunicationHelper.getBusinessPhoneNumber();
    final businessEmail = BookingCommunicationHelper.getBusinessEmail();

    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final social = details.social;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OUR STUDIOS & SHOWROOMS",
            style: GoogleFonts.italiana(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Studio Cards
          ...studios.map((studio) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF142620),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldColor.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: goldColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          studio.name,
                          style: GoogleFonts.italiana(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studio.fullAddress,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => StudioLocationsHelper.openInGoogleMaps(studio.fullAddress),
                        icon: Icon(Icons.map_outlined, size: 13, color: goldColor),
                        label: Text(
                          "View Map",
                          style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => StudioLocationsHelper.getDirections(studio.fullAddress),
                        icon: const Icon(Icons.directions_outlined, size: 13, color: Color(0xFF0F1B18)),
                        label: Text(
                          "Directions",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: const Color(0xFF0F1B18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          Text(
            "DIRECT COMMUNICATION",
            style: GoogleFonts.italiana(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Phone Action
          _buildActionRow(
            icon: Icons.phone_outlined,
            title: "Voice Calling",
            subtitle: BookingCommunicationHelper.formatDisplayPhone(businessPhone),
            goldColor: goldColor,
            onTap: () => BookingCommunicationHelper.openCall(),
          ),
          const SizedBox(height: 10),

          // WhatsApp Action
          _buildActionRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: "WhatsApp Chat",
            subtitle: "Instant Consultation & Styling Chat",
            goldColor: const Color(0xFF4EBA7A),
            onTap: () => BookingCommunicationHelper.openWhatsApp(
              message: BookingCommunicationHelper.generateGeneralInquiryMessage(),
            ),
          ),
          const SizedBox(height: 10),

          // Email Action
          _buildActionRow(
            icon: Icons.mail_outline_rounded,
            title: "Email Inquiries",
            subtitle: businessEmail,
            goldColor: goldColor,
            onTap: () => BookingCommunicationHelper.openEmail(),
          ),
          const SizedBox(height: 10),

          // Service Area Link
          _buildActionRow(
            icon: Icons.map_rounded,
            title: "Service Area & Travel Policy",
            subtitle: "Check delivery zones & pincodes across Gujarat",
            goldColor: goldColor,
            onTap: () => Get.toNamed(AppRoutes.serviceArea),
          ),

          const SizedBox(height: 24),

          // Social Media Links (Non-empty only)
          Text(
            "FOLLOW OUR CELEBRATIONS",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: goldColor,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (social.instagram.isNotEmpty || social.instagramKadi.isNotEmpty)
                _buildSocialChip(
                  label: "Instagram",
                  url: social.instagram.isNotEmpty ? social.instagram : social.instagramKadi,
                  goldColor: goldColor,
                ),
              if (social.facebook.isNotEmpty)
                _buildSocialChip(
                  label: "Facebook",
                  url: social.facebook,
                  goldColor: goldColor,
                ),
              if (social.youtube.isNotEmpty)
                _buildSocialChip(
                  label: "YouTube",
                  url: social.youtube,
                  goldColor: goldColor,
                ),
              if (social.pinterest.isNotEmpty)
                _buildSocialChip(
                  label: "Pinterest",
                  url: social.pinterest,
                  goldColor: goldColor,
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSocialChip({required String label, required String url, required Color goldColor}) {
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF142620),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_outward_rounded, size: 12, color: goldColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color goldColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13251F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: goldColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, Color goldColor) {
    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: const Color(0xFF12241E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldColor.withValues(alpha: 0.3)),
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
              "Your message has been submitted successfully.\nWe'll get back to you soon.",
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF12241E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.22)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SEND US AN INQUIRY",
              style: GoogleFonts.italiana(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "Share your event vision and our lead stylists will prepare a consultation.",
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // Name
            _buildFieldLabel("FULL NAME *", goldColor),
            TextFormField(
              controller: _nameController,
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
              validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your full name." : null,
              decoration: _inputDecoration("e.g. Priyaben Patel", Icons.person_outline, goldColor),
            ),
            const SizedBox(height: 16),

            // Phone
            _buildFieldLabel("PHONE NUMBER * (10 DIGITS)", goldColor),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Please enter your phone number.";
                final clean = v.replaceAll(RegExp(r'\D'), '');
                if (clean.length < 10) return "Please enter a valid 10-digit phone number.";
                return null;
              },
              decoration: _inputDecoration("e.g. 9512149944", Icons.phone_outlined, goldColor),
            ),
            const SizedBox(height: 16),

            // Email (Optional)
            _buildFieldLabel("EMAIL ADDRESS (OPTIONAL)", goldColor),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) return "Please enter a valid email address.";
                }
                return null;
              },
              decoration: _inputDecoration("e.g. priya@gmail.com", Icons.email_outlined, goldColor),
            ),
            const SizedBox(height: 16),

            // Event Type
            _buildFieldLabel("EVENT TYPE", goldColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E19),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldColor.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEventType,
                  dropdownColor: const Color(0xFF142620),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedEventType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estimated Date
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
                          surface: const Color(0xFF12241E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E19),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: goldColor.withValues(alpha: 0.2)),
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
                        fontSize: 13,
                        color: _selectedDate != null ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message
            _buildFieldLabel("MESSAGE / SPECIAL REQUIREMENTS *", goldColor),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 500,
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Please enter your message.";
                if (v.trim().length < 10) return "Message must be at least 10 characters.";
                return null;
              },
              decoration: InputDecoration(
                hintText: "Tell us about your venue, theme preferences, special requests...",
                hintStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0F1E19),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: goldColor),
                ),
                counterStyle: AppTheme.sansBody(fontSize: 10, color: Colors.white38),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitInquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: const Color(0xFF0F1B18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0F1B18),
                        ),
                      )
                    : Text(
                        "SUBMIT INQUIRY",
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: const Color(0xFF0F1B18),
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
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: AppTheme.sansBody(
          fontSize: 10,
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
      prefixIcon: Icon(icon, size: 16, color: goldColor.withValues(alpha: 0.7)),
      filled: true,
      fillColor: const Color(0xFF0F1E19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
