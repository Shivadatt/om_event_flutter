import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../domain/entities/business_details_entity.dart';

part 'parts/footer_grid.dart';

class FooterSection extends StatelessWidget {
  final bool isDesktop;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;

  const FooterSection({
    super.key,
    required this.isDesktop,
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 32.0;

    return Container(
      color: const Color(0xFF0F1B18), // Primary Background
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 72,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            final originalDetails = BusinessDetailsService.to.rxDetails.value;
            final footer = AppConfigService.to.rxFooterSettings.value;
            final contactSettings = AppConfigService.to.rxContactSettings.value;
            final businessProfile = AppConfigService.to.rxBusinessProfile.value;

            // 1. Resolve office branches from all settings documents
            List<BranchEntity> resolvedBranches = [];
            for (final b in originalDetails.branches) {
              if (b.branchName.isNotEmpty && b.fullAddress.isNotEmpty) {
                resolvedBranches.add(b);
              }
            }

            if (resolvedBranches.isEmpty) {
              for (final b in businessProfile.officeBranches) {
                if (b.branchName.isNotEmpty && b.address.isNotEmpty) {
                  resolvedBranches.add(BranchEntity(
                    id: b.id,
                    branchName: b.branchName,
                    branchManager: '',
                    phoneNumber: b.phone1.isNotEmpty ? b.phone1 : b.phone2,
                    whatsapp: b.whatsapp,
                    email: b.email,
                    fullAddress: b.address,
                    googleMapUrl: b.googleMapUrl,
                    latitude: b.latitude,
                    longitude: b.longitude,
                    workingHours: b.businessHours,
                    openingDays: '',
                    displayOrder: b.isPrimary ? 1 : 2,
                    isActive: true,
                    instagram: b.instagram,
                  ));
                }
              }
            }

            if (resolvedBranches.isEmpty) {
              for (final e in contactSettings.branches) {
                if (e is Map) {
                  final b = Map<String, dynamic>.from(e);
                  final name = b['branchName'] ?? b['name'] ?? '';
                  final addr = b['address'] ?? b['fullAddress'] ?? '';
                  if (name.isNotEmpty && addr.isNotEmpty) {
                    resolvedBranches.add(BranchEntity(
                      id: b['id'] ?? '',
                      branchName: name,
                      branchManager: b['branchManager'] ?? '',
                      phoneNumber: b['phone1'] ?? b['phone'] ?? b['phoneNumber'] ?? b['phone2'] ?? '',
                      whatsapp: b['whatsapp'] ?? '',
                      email: b['email'] ?? '',
                      fullAddress: addr,
                      googleMapUrl: b['googleMapUrl'] ?? b['googleMaps'] ?? '',
                      latitude: b['latitude'] ?? '',
                      longitude: b['longitude'] ?? '',
                      workingHours: b['businessHours'] ?? b['workingHours'] ?? '',
                      openingDays: b['openingDays'] ?? '',
                      displayOrder: (b['isPrimary'] ?? false) ? 1 : 2,
                      isActive: b['isActive'] ?? true,
                      instagram: b['instagram'] ?? '',
                    ));
                  }
                }
              }
            }

            // 2. Resolve contact phones (collect, merge, format, and de-duplicate)
            List<ContactItemEntity> resolvedPhones = [];
            resolvedPhones.addAll(originalDetails.contacts.phones.where((p) => p.value.isNotEmpty));

            for (final c in businessProfile.contactNumbers) {
              if (c.number.isNotEmpty) {
                resolvedPhones.add(ContactItemEntity(
                  id: c.id,
                  label: c.label,
                  value: c.number,
                  isPrimary: c.isPrimary,
                  isActive: c.isActive,
                  displayOrder: c.displayOrder,
                ));
              }
            }

            if (contactSettings.phone.isNotEmpty) {
              final parts = contactSettings.phone.split(RegExp(r'[,\s/]+'));
              for (var i = 0; i < parts.length; i++) {
                final cleanPart = parts[i].trim();
                if (cleanPart.isNotEmpty) {
                  resolvedPhones.add(ContactItemEntity(
                    id: 'contact_phone_$i',
                    label: i == 0 ? 'Primary' : 'Phone',
                    value: cleanPart,
                    isPrimary: i == 0,
                    isActive: true,
                    displayOrder: i + 1,
                  ));
                }
              }
            }

            for (final branch in resolvedBranches) {
              if (branch.phoneNumber.isNotEmpty) {
                resolvedPhones.add(ContactItemEntity(
                  id: 'branch_phone_${branch.id}',
                  label: branch.branchName.toLowerCase().contains('main') || branch.branchName.toLowerCase().contains('kadi') ? 'Primary' : 'Phone',
                  value: branch.phoneNumber,
                  isPrimary: false,
                  isActive: true,
                  displayOrder: 10,
                ));
              }
            }

            final seenPhoneValues = <String>{};
            final uniquePhones = <ContactItemEntity>[];
            for (final p in resolvedPhones) {
              final norm = p.value.replaceAll(RegExp(r'\D'), '');
              final norm10 = norm.length >= 10 ? norm.substring(norm.length - 10) : norm;
              if (norm10.isNotEmpty && !seenPhoneValues.contains(norm10)) {
                seenPhoneValues.add(norm10);
                uniquePhones.add(p);
              }
            }
            resolvedPhones = uniquePhones;

            // 3. Resolve emails
            List<ContactItemEntity> resolvedEmails = [];
            resolvedEmails.addAll(originalDetails.contacts.emails.where((e) => e.value.isNotEmpty));
            if (businessProfile.email.isNotEmpty) {
              resolvedEmails.add(ContactItemEntity(
                id: 'bus_email',
                label: 'Email',
                value: businessProfile.email,
                isPrimary: true,
                isActive: true,
                displayOrder: 1,
              ));
            }
            if (contactSettings.email.isNotEmpty) {
              resolvedEmails.add(ContactItemEntity(
                id: 'cont_email',
                label: 'Email',
                value: contactSettings.email,
                isPrimary: true,
                isActive: true,
                displayOrder: 1,
              ));
            }
            for (final branch in resolvedBranches) {
              if (branch.email.isNotEmpty) {
                resolvedEmails.add(ContactItemEntity(
                  id: 'branch_email_${branch.id}',
                  label: 'Email',
                  value: branch.email,
                  isPrimary: false,
                  isActive: true,
                  displayOrder: 10,
                ));
              }
            }
            final seenEmailValues = <String>{};
            final uniqueEmails = <ContactItemEntity>[];
            for (final e in resolvedEmails) {
              final lowerVal = e.value.toLowerCase().trim();
              if (lowerVal.isNotEmpty && !seenEmailValues.contains(lowerVal)) {
                seenEmailValues.add(lowerVal);
                uniqueEmails.add(e);
              }
            }
            resolvedEmails = uniqueEmails;

            // 4. Resolve social links (with fallbacks to office branch properties)
            String instagramKadi = originalDetails.social.instagramKadi.isNotEmpty
                ? originalDetails.social.instagramKadi
                : (businessProfile.socialLinks['instagram_kadi'] ?? '');
            String instagramThangadh = originalDetails.social.instagramThangadh.isNotEmpty
                ? originalDetails.social.instagramThangadh
                : (businessProfile.socialLinks['instagram_thangadh'] ?? '');

            for (final branch in resolvedBranches) {
              if (branch.instagram.isNotEmpty) {
                final lowerName = branch.branchName.toLowerCase();
                final lowerAddress = branch.fullAddress.toLowerCase();
                if (lowerName.contains('kadi') || lowerAddress.contains('kadi') || lowerName.contains('medha') || lowerAddress.contains('medha')) {
                  if (instagramKadi.isEmpty) instagramKadi = branch.instagram;
                } else if (lowerName.contains('thangadh') || lowerAddress.contains('thangadh') || lowerName.contains('surajdeval') || lowerAddress.contains('surajdeval')) {
                  if (instagramThangadh.isEmpty) instagramThangadh = branch.instagram;
                } else {
                  if (instagramKadi.isEmpty) {
                    instagramKadi = branch.instagram;
                  } else if (instagramThangadh.isEmpty) {
                    instagramThangadh = branch.instagram;
                  }
                }
              }
            }

            final social = SocialMediaEntity(
              instagramKadi: instagramKadi,
              instagramThangadh: instagramThangadh,
              website: originalDetails.social.website.isNotEmpty
                  ? originalDetails.social.website
                  : (businessProfile.socialLinks['website'] ?? ''),
              googleBusinessProfile: originalDetails.social.googleBusinessProfile.isNotEmpty
                  ? originalDetails.social.googleBusinessProfile
                  : (businessProfile.socialLinks['google_business_profile'] ?? ''),
            );

            // 5. Build resolved BusinessDetailsEntity
            final details = BusinessDetailsEntity(
              general: originalDetails.general,
              contacts: ContactDetailsEntity(
                phones: resolvedPhones,
                whatsapps: originalDetails.contacts.whatsapps,
                emails: resolvedEmails,
                customerCares: originalDetails.contacts.customerCares,
                emergencyContacts: originalDetails.contacts.emergencyContacts,
              ),
              branches: resolvedBranches,
              addresses: originalDetails.addresses,
              social: social,
              workingHours: originalDetails.workingHours,
              bank: originalDetails.bank,
              legal: originalDetails.legal,
              seo: originalDetails.seo,
              maps: originalDetails.maps,
            );

            final activePhones = details.contacts.phones.where((c) => c.isActive).toList();
            final activeEmails = details.contacts.emails.where((e) => e.isActive).toList();

            final sortedBranches = List<BranchEntity>.from(
              details.branches.where((b) => b.isActive),
            );
            sortedBranches.sort(
              (a, b) => a.displayOrder.compareTo(b.displayOrder),
            );

            String branchesText = "";
            if (sortedBranches.isNotEmpty) {
              final buffer = StringBuffer();
              for (var i = 0; i < sortedBranches.length; i++) {
                final b = sortedBranches[i];
                buffer.write("Branch - ${i + 1}: ${b.fullAddress}");
                if (i < sortedBranches.length - 1) {
                  buffer.write(",\n");
                }
              }

              String locationLine = "Gujarat India 382715";
              if (businessProfile.officeBranches.isNotEmpty) {
                final primary = businessProfile.officeBranches.firstWhere(
                  (b) => b.isPrimary,
                  orElse: () => businessProfile.officeBranches.first,
                );
                if (primary.state.isNotEmpty && primary.pincode.isNotEmpty) {
                  locationLine = "${primary.state} ${primary.country} ${primary.pincode}".replaceAll(RegExp(r'\s+'), ' ').trim();
                }
              }
              buffer.write("\n$locationLine");
              branchesText = buffer.toString();
            } else {
              branchesText = contactSettings.address;
            }

            if (isDesktop) {
              return _buildDesktopFooter(
                details,
                footer,
                activePhones,
                activeEmails,
                branchesText,
              );
            } else {
              return _buildMobileFooter(
                details,
                footer,
                activePhones,
                activeEmails,
                branchesText,
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String copyright) {
    return Text(
      copyright.toUpperCase(),
      style: AppTheme.sansBody(
        fontSize: 9,
        color: Colors.white.withValues(alpha: 0.35),
        letterSpacing: 1,
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (val) => setState(() => _isHovered = val),
        child: Text(
          widget.label,
          style: AppTheme.sansBody(
            fontSize: 12.5,
            color: _isHovered ? AppColors.secondaryAccent : Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _FooterTextLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterTextLink({required this.label, required this.onTap});

  @override
  State<_FooterTextLink> createState() => _FooterTextLinkState();
}

class _FooterTextLinkState extends State<_FooterTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (val) => setState(() => _isHovered = val),
      child: Text(
        widget.label,
        style: AppTheme.sansBody(
          fontSize: 9,
          color: _isHovered ? AppColors.secondaryAccent : AppColors.secondaryAccent.withValues(alpha: 0.7),
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
